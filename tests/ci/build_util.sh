#!/bin/bash
set -x

set -e

function s3_to_https() {
  local s3_url="$1"

  if [[ "$s3_url" =~ ^s3://([^/]+)/(.+)$ ]]; then
    local bucket="${BASH_REMATCH[1]}"
    local path="${BASH_REMATCH[2]}"
    # current s3 bucket is create in this region
    local region="us-east-1"  
    echo "https://${bucket}.s3.${region}.amazonaws.com/${path}"
  else
    echo "Invalid S3 URL: $s3_url" >&2
    return 1
  fi
}


function uploader {
  # Accepts: $1=file_name, $2=target_bucket, $3=aws_region
  local file_path="$1"
  local s3_bucket="$2"
  local aws_region="$3"  # <-- Capture the new region parameter
  local file_path="${file_name}" # NEW LINE for consistency
  local target_bucket="${s3_bucket}"
  converted_url=$(s3_to_https "s3://$target_bucket/$file_name")
  echo "download url $converted_url"
  aws s3 cp "$file_name" "s3://$target_bucket/$file_name" --region "$aws_region"
}
function publishImage {
    echo "Publishing images to Docker Hub..."
    echo "The images on the host:"
    # for main, will use 'dev' as the tag name
    # for release-*, will use 'release-*-dev' as the tag name, like release-v1.8.0-dev
    if [[ $1 == "main" ]]; then
      image_tag=dev
    fi
    if [[ $1 == "release-"* ]]; then
      image_tag=$2-dev
    fi
    # rename the images with tag "dev" and push to Docker Hub
    docker images
    docker login -u $3 -p $4
    docker images | grep goharbor | grep -v "\-base" | sed -n "s|\(goharbor/[-._a-z0-9]*\)\s*\(.*$2\).*|docker tag \1:\2 \1:$image_tag;docker push \1:$image_tag|p" | bash
    echo "Images are published successfully"
    docker images
}