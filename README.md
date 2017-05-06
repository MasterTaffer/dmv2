# dmv2
DMV2 encoder: encodes sequences of images (i.e. animation) into a completely made up format called DMV2. 

## What exactly is DMV2 format?

It is a single color format designed for videos of moving white shapes on black background (or vice versa). One strong requirement for the format was to be easily decodeable with low CPU usage.

The DMV2 format encodes the images with a grid of "gradient blocks". These blocks have exactly 256 different possible forms which guarantees a quite aggressive compression. Only the first frame is a "gradient block" frame: the rest provide only differences to the previous frame ("difference" frames). Because the "difference" frames contain only the differences between the frames, to decode a specific frame all the previous frames must be decoded as well. This also means that if one frame is corrupted, the rest of the frames are corrupted as well.

While the algorithm is not the most sophisticated and surely better algorithms exist, it serves its (weirdly specific) purpose. DMV2 was made with decoding speed and simplicity in mind.

An epilepsy inducing demonstration may be viewed [here.](https://www.youtube.com/watch?v=wC2hwEWZobo)

## Compiling

Compile with [DUB](https://code.dlang.org/getting_started). Uses the [imageformats](https://code.dlang.org/packages/imageformats) package for image manipulation. 

## Usage of the tool

First get your images in a single folder all in PNG format. Then invoke

    dmv2 outputfile.dmv2 path_to_your_folder_here

The program will take all images in the folder and sort them by the name. They are then encoded in the DMV2 format and saved to outputfile.dmv2.
