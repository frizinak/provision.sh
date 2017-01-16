#! /bin/bash

help_text <<EOF
Find regions with the least amount of information in an image.
EOF

include go

apt_repo ppa xqms/opencv-nonfree

install libopencv-calib3d2.4v5 \
    libopencv-contrib2.4v5 \
    libopencv-core2.4v5 \
    libopencv-features2d2.4v5 \
    libopencv-flann2.4v5 \
    libopencv-gpu2.4v5 \
    libopencv-highgui2.4v5 \
    libopencv-imgproc2.4v5 \
    libopencv-legacy2.4v5 \
    libopencv-ml2.4v5 \
    libopencv-objdetect2.4v5 \
    libopencv-ocl2.4v5 \
    libopencv-photo2.4v5 \
    libopencv-stitching2.4v5 \
    libopencv-superres2.4v5 \
    libopencv-ts2.4v5 \
    libopencv-video2.4v5 \
    libopencv-videostab2.4v5 \
    libopencv-nonfree2.4v5 \
    libopencv-nonfree-dev \
    libopencv-dev

go get github.com/lazywei/go-opencv
go get -u "github.com/wieni/go-imgrect"
fix_user_perms "${webuser}"

service "$1/imgrect.service" \
    bin="/home/${webuser}/go/bin/go-imgrect" \
    user="${webuser}"

