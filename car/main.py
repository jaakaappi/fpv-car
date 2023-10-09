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

servoPIN = 14
GPIO.setmode(GPIO.BCM)
GPIO.setup(servoPIN, GPIO.OUT)
p = GPIO.PWM(servoPIN, 50) # GPIO 17 for PWM with 50Hz

# servo range 5-7.5
p.start(6.25)
time.sleep(1)

servomotor = servo.Servo(pca.channels[7])
servomotor.angle = 90
motor = servo.Servo(pca.channels[0])
motor.angle = 110

def set_throttle (throttle):
    if throttle >= 110 and throttle <= 120:
        motor.angle = throttle
    else:
        raise Exception("Bad throttle value")

try:
    print("Waiting for connection")
    while True:
        data, addr = sock.recvfrom(8) # bytes
        print("received message: %s" % data, len(data))

        first_part = data[:4]
        second_part = data[4:]
        print(first_part, second_part)

        steering = struct.unpack('<f', first_part)[0]
        print("steering ", steering)
        if steering >= -50 and steering <= 50:
            # (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
            servo_angle = (((steering + 50) * 140) / 100) + 20
            print(servo_angle)
            servomotor.angle = servo_angle
            # servo_steering = (((steering - -50) * 2.5) / 100) + 5
            # print(servo_steering)
            # p.ChangeDutyCycle(servo_steering)

        throttle = struct.unpack('<f', second_part)[0]
        print("throttle ", throttle)
        if throttle >= 0 and throttle <= 100:
            # forward --- 110 +++ backwards?
            # (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
            motor_throttle = (((throttle) * 10) / 100) + 110
            print(motor_throttle)
            set_throttle(motor_throttle)
except KeyboardInterrupt:
    servomotor.angle = 90
    motor.angle = 110
    p.stop()
    pca.deinit()
    GPIO.cleanup()
except Exception as error:
    print("error: ", error)
    servomotor.angle = 90
    motor.angle = 110
    p.stop()
    pca.deinit()
    GPIO.cleanup()