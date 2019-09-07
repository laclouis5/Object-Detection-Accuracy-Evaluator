#  Documentation
Swift 5 implementation of mAP computation for Yolo-style detections.

## Yolo-Style Format for Annotations
One TXT file for each image. Detections should be stored in  `detection-results` folder and ground truth in `ground-truth`. Coordinates are relative to the image size. Images should be stores as `.jpg` files in `image` folder.

File format for detections:
```
<label> <confidence> <x> <y> <w> <h>
<label> <confidence> <x> <y> <w> <h>
...
````

File format for ground truth:
```
<label> <x> <y> <w> <h>
<label> <x> <y> <w> <h>
...
````

## TODO
Optimize `getBoundingBoxesBy...()` methods.
