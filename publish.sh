#!/usr/bin/env bash

TARGET_REGION="us-east-1"
aws configure set default.region "$TARGET_REGION" --profile default

CHROMIUM_VERSION=109
LAYER_NAME='chromium'
LAYER_DESCRIPTION="Chromium v${CHROMIUM_VERSION}"
S3_BUCKET_NAME=exoticca-lambda-layers-"$TARGET_REGION"

aws s3 cp \
  ~/chromium/chromium.zip \
  s3://"$S3_BUCKET_NAME"/chromium.zip

aws lambda add-layer-version-permission \
  --region "$TARGET_REGION" \
  --layer-name "$LAYER_NAME" \
  --statement-id sid1 \
  --action lambda:GetLayerVersion \
  --principal '*' \
  --version-number "$(
    aws lambda publish-layer-version \
      --region "$TARGET_REGION" \
      --layer-name "$LAYER_NAME" \
      --description "$LAYER_DESCRIPTION" \
      --query Version \
      --output text \
      --content S3Bucket="$S3_BUCKET_NAME",S3Key=chromium.zip
  )"
