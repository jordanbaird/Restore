#!/bin/bash

swift package \
  --allow-writing-to-directory ./docs \
    generate-documentation \
      --target Restore \
      --disable-indexing \
      --transform-for-static-hosting \
      --hosting-base-path Restore \
      --output-path ./docs
