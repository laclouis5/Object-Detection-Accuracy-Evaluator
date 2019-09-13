# Object Detection Accuracy Evaluation in Swift 5

Swift 5 implementation of mAP computation for Yolo-style detections. The App shows stats about the database as well as evaluation stats (True Positive, ...).

![App View](https://github.com/laclouis5/ObjectDetectionEvaluator/blob/master/App%20Image.png "Main View of the App")

## Data Format
* Two TXT files for each image: one for ground truths and one for detections. Detection file name must match groundtruth file name, i.e detections for GT `im_0123.txt` are stored in a file with the same name: `im_0123.txt`.
* Coordinates are Yolo-style (other formats available soon), that is to say `(x, y)` is the box center and `(w, h)` its size. Coordinates are relative to the image size i.e. floats in 0..1.

Format for detections:
```
<label> <confidence> <x> <y> <w> <h>
<label> <confidence> <x> <y> <w> <h>
...
````

Format for ground truths:
```
<label> <x> <y> <w> <h>
<label> <x> <y> <w> <h>
...
````

* `label` is anything hashable (Int, Float, String, ...).
* `confidence` score is a float in 0..1.

## How to Use
* Clone the repo on your Mac
* Build and run the app using Xcode
* Select folders where detections and ground truths are stored
* Check in the top and left panel that everything went well (number of classes, number of images and annotations...)
* Launch the evaluation and see the results in the right panel

## TODO
- [ ] Parallelize file reading in `YoloParser` for speedup
- [ ] Add a selector for the input format (XYWH, XYX2Y2, relative, absolute)
- [x] Add methods for mAP computation
- [ ] Logs for errors during reading
- [x] Background queue for file reading and evaluation
- [x] Graphical interface
- [x] Optimize getters in `Evaluator` (Speed x10)
