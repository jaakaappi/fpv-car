import argparse
import socket
import struct
import time

import busio
import RPi.GPIO as GPIO
from adafruit_motor import servo
from adafruit_pca9685 import PCA9685
from board import SCL, SDA

i2c = busio.I2C(SCL, SDA)
pca = PCA9685(i2c)
pca.frequency = 50

parser = argparse.ArgumentParser()
parser.add_argument("port")
args = parser.parse_args()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", int(args.port)))
sock.settimeout(0.5)

servoPIN = 14
GPIO.setmode(GPIO.BCM)
GPIO.setup(servoPIN, GPIO.OUT)
p = GPIO.PWM(servoPIN, 50) # GPIO 17 for PWM with 50Hz

# servo range 5-7.5
p.start(6.25)
time.sleep(1)

servo_trim = 20
servomotor = servo.Servo(pca.channels[7])
servomotor.angle = 90
motor = servo.Servo(pca.channels[0])
motor.angle = 110

def set_throttle (throttle):
    # failsafe for bad math
    if throttle <= 110 and throttle >= 100:
        motor.angle = throttle
    else:
        raise Exception("Bad throttle value")

def reset_servo_and_motor():
    servomotor.angle = 90
    motor.angle = 110

def cleanup_IO():
    p.stop()
    pca.deinit()
    GPIO.cleanup()

try:
    print("Waiting for connection")
    while True:
        try:
            data, addr = sock.recvfrom(8) # bytes
            print("received message: %s" % data, len(data))

            first_part = data[:4]
            second_part = data[4:]
            print(first_part, second_part)

            steering = struct.unpack('<f', first_part)[0]
            print("steering ", steering)
            if steering >= -50 and steering <= 50:
                # (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
                servo_angle = (((steering + 50) * (180-servo_trim)) / 100)+servo_trim
                print(servo_angle)
                servomotor.angle = servo_angle

            throttle = struct.unpack('<f', second_part)[0]
            print("throttle ", throttle)
            if throttle >= 0 and throttle <= 100:
                # forward --- 110 +++ backwards
                # (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
                motor_throttle = (((throttle*-1) * 10) / 100) + 110
                print(motor_throttle)
                set_throttle(motor_throttle)
        # check every 0.5s if we are receiving data, stop if not
        except socket.timeout:
            reset_servo_and_motor()
except KeyboardInterrupt:
    reset_servo_and_motor()
    cleanup_IO()
except Exception as error:
    print("error: ", error)
    reset_servo_and_motor()
    cleanup_IO()