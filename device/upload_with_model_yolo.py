from datetime import datetime
from EventClipper import KeyClipWriter
from ultralytics import YOLO
from threading import Thread
from firebase_admin import credentials, initialize_app, storage, firestore_async
import numpy as np
import RPi.GPIO as GPIO
import cv2
import time
import os
import random
import sys
import importlib.util
import asyncio

model = YOLO("best.pt")
#model.predict(source=0,show=True)
triggerPin = 18
echoPin = 17
servoPin = 27
angle = 73
fps = 10
width = 320
height = 320
delay = int(1000/fps)
#2.5sec long video for 64 bufsize
bufSize = 300
fourcc = cv2.VideoWriter_fourcc('M','J','P','G')

frame_rate_calc = 5
freq = cv2.getTickFrequency()

# Initialize video stream
videostream = cv2.VideoCapture(0)
videostream.set(3, width)
videostream.set(4, height)
time.sleep(1)
cred = credentials.Certificate("accountKey.json")
initialize_app(cred, {'storageBucket': 'capstone-design-94717.appspot.com'})
db = firestore_async.client()
document_name = datetime.today().isoformat()

async def save_to_firestore(data):
    await db.collection("messages").document(document_name).set({"msg": data})
    print("msg sent")

kcw = KeyClipWriter(bufSize = bufSize)
consecFrames = 0
class_names = ['barrigate', 'sculpture', 'stop', 'bench', 'stone',
               'collectionbox', 'tree', 'bollard', 'colorcone', 'burlapbag',
               'bicycle', 'fitnessequipment', 'table', 'trashcan', 'drinkingfountain',
               'person', 'crack', 'kickboard', 'car', 'cart', 'sign', 'stand',
               'outdoorunit', 'motorcycle', 'signboard', 'rides', 'pot', 'box',
               'chair', 'powerpole', 'trash']

def distance():
      s=0
      t=0
      GPIO.output(triggerPin, True)  
      time.sleep(0.00001) 
      GPIO.output(triggerPin, False)

   
      while GPIO.input(echoPin) == 0:  
         s = time.time()
      while GPIO.input(echoPin) == 1: 
         t = time.time()

      rtTotime = t-s
      distance = rtTotime * (34000 / 2 )
      return distance

async def main():
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)

    GPIO.setup(triggerPin, GPIO.OUT)   
    GPIO.setup(echoPin, GPIO.IN)        
    GPIO.setup(servoPin, GPIO.OUT)
    GPIO.output(triggerPin, False)
    pwm = GPIO.PWM(servoPin,50)
    pwm.start(3.0)

    distance_list = [float("inf") for i in range(angle)]
    global consecFrames
    
    while True:
        # Start timer (for calculating frame rate)
        t1 = cv2.getTickCount()
        updateConsecFrames = True
        # Grab frame from video stream
        ret, frame1 = videostream.read()

        # Acquire frame and resize to expected shape [1xHxWx3
        predictions = model.predict(frame1, conf = 0.5)
        for high_time in range(0,angle-1):
                pwm.ChangeDutyCycle((high_time+53)/10.0)
                distance_list[high_time]=distance()
                time.sleep(0.1)
        for high_time in range(0,angle-1):
                pwm.ChangeDutyCycle((angle-1-(high_time+53))/10.0)
                distance_list[high_time]=distance()
                time.sleep(0.1)

        if len(predictions) > 0 and len(predictions[0].boxes) > 0:
            results_to_save = []
            results_to_save.append({
                'cls': predictions[0].boxes.cls.cpu().numpy().astype(int),    
                'xywh': predictions[0].boxes.xywh.cpu().numpy().astype(int),
                'confs': predictions[0].boxes.conf.cpu().numpy().astype(float),
            })

            # Show the frame with predictions
            for obj in results_to_save:
                message_data = ''
                cls = obj['cls'][0]
                xywh = obj['xywh'][0]
                conf = obj['confs'][0]

                # Draw rectangle
                x, y, w, h = xywh
                cv2.rectangle(frame1, (x, y), (x + w, y + h), (0, 255, 0), 2)
                if x > 0 and x < 106: direction = "left"
                elif x >= 106 and x < 212: direction = "front"
                else: direction = "right"

                if direction == "left":
                    dist = min(distance_list[:24])
                elif direction == "front":
                    dist = min(distance_list[24:48])
                else:
                    dist = min(distance_list[48:])

                # Display class name and confidence score
                label = f'{class_names[cls]}is detected {direction} {dist}m'
                message_data = label
                cv2.putText(frame1, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
                await save_to_firestore(message_data)
                
                #asyncio.get_event_loop().run_until_complete(save_to_firestore(message_data))


        

        #print(results_to_save)
        
        # Show the frame with predictions
        cv2.imshow("Frame", frame1)

        # Calculate framerate
        t2 = cv2.getTickCount()
        time1 = (t2 - t1) / freq
        frame_rate_calc = 1 / time1
        pressedKey = cv2.waitKey(1) & 0xFF
        # Press 'q' to quit
        if pressedKey == ord('q'):
            break
        elif pressedKey == ord('t'):
            print("t is entered.")
            
            updateConsecFrames = False
            # if we are not already recording, start recording
            if not kcw.recording:
                timestamp = datetime.now()
                p = "{}/{}.avi".format(os.getcwd(), timestamp.strftime("%H_%M_%S"))
                kcw.start(p, fourcc, fps)
                print("Event video saved: {}".format(p))
                time.sleep(5)
                fileName = p
                bucket = storage.bucket()
                blob = bucket.blob(fileName)
                blob.upload_from_filename(fileName)

    # Opt : if you want to make public access from the URL
                blob.make_public()

                print("your file url", blob.public_url)
        #if time.time() - start_time > 10:
         #   start_time = time.time()
          #  video_file_name = datetime.today().strftime("%H:%M:%S")
           # video_file = os.path.join(save_dir, str(video_file_name) + ".mp4")
            #video_writer = cv2.VideoWriter(
            #    video_file, video_codec, fps, (int(cap.get(3)), int(cap.get(4)))
           # )
           # print("Capture video saved location: {}".format(video_file))

        # Write the frame to the current video writer
        if updateConsecFrames:
            consecFrames += 1
            #print(consecFrames)
        kcw.update(frame1)

        if kcw.recording and consecFrames >= bufSize:
            kcw.finish()
            print("buffer full, finish recordig")
            

    # Clean up
    cv2.destroyAllWindows()
    videostream.release()

loop = asyncio.get_event_loop()
try:
    loop.run_until_complete(main())
except KeyboardInterrupt:
    pass
finally:
    loop.close()


