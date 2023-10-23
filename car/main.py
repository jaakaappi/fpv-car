import argparse
import math
import socket
import struct
import time

import busio
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

servo_trim = 20
servomotor = servo.Servo(pca.channels[7])
servomotor.angle = 90
motor = servo.Servo(pca.channels[0])
motor.angle = 110
# needed for the ESC to wake up
time.sleep(0.5)

def set_throttle (throttle):
    # failsafe for bad math
    if throttle <= 135 and throttle >= 100:
        motor.angle = throttle
    else:
        raise Exception("Bad throttle value")

def reset_servo_and_motor():
    servomotor.angle = 90
    motor.angle = 110

def stop_car():
    set_throttle(110)

def cleanup_IO():
    pca.deinit()

try:
    print("Waiting for connection")

    reverse_init = False

    while True:
        try:
            data, addr = sock.recvfrom(16) # bytes
            print("received message: %s" % data, len(data))

            first_part = data[:4]
            second_part = data[4:8]
            thrid_part = data[8:]
            print(first_part, second_part, thrid_part)

            steering = struct.unpack('<f', first_part)[0]
            print("steering ", steering)
            if steering >= -50 and steering <= 50:
                # (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
                servo_angle = (((steering + 50) * (180-servo_trim)) / 100)+servo_trim
                print(servo_angle)
                servomotor.angle = servo_angle

            reverse = struct.unpack('<f', thrid_part)[0]
            print("reverse ", reverse)
            if math.isclose(reverse, 1):
                if not reverse_init:
                    stop_car()
                    time.sleep(0.2)
                    reverse_init = True
                # forward --- 110 +++ backwards
                # reversing starts from 130ish
                reverse_throttle = 135 # static low speed reverse for now
                print(reverse_throttle)
                set_throttle(reverse_throttle)

            throttle = struct.unpack('<f', second_part)[0]
            print("throttle ", throttle)
            if throttle >= 0 and throttle <= 100 and reverse < 1: # not reversing
                # forward --- 110 +++ backwards
                # (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
                motor_throttle = (((throttle*-1) * 10) / 100) + 110
                print(motor_throttle)
                set_throttle(motor_throttle)

                if reverse_init:
                    reverse_init = False

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