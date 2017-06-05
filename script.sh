#!/usr/bin/env bash
usage() {
cat << EOF
required
./script.sh --name <name> <source>

OPTIONS:
  -h              help

REQUIRED OPTIONS:
  --name -n       service name

OPTIONAL:
  --is-index      is index page
EOF
}

# check if awscli is installed
hash aws 2>/dev/null || { echo >&2 "Require aws-cli to be installed run pip install awscli"; exit 1; }

# Extract required variables from supplied flags
# awsDefaultRegion=$AWS_DEFAULT_REGION
# awsAccessKeyId=$AWS_ACCESS_KEY_ID
# awsSecretAccessKey=$AWS_SECRET_ACCESS_KEY

# get variables from command line flags
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -n|--name*)
      shift
      name=$1
      shift
      ;;
    --is-index*)
      shift
      isIndex=true
      ;;
    *)
      break
      ;;
  esac
done

source=$1

# Check if required args are passed in
if [[ -z $name ]] || [[ -z $source ]]; then
  usage
  exit 1
fi

make_bucket() {
  name=$1
  isIndex=$2

  # aws s3api create-bucket --bucket $name &&
  aws s3 mb s3://$name &&
  aws s3api put-bucket-policy --bucket $name --policy "$(echo '{
    "Version":"2012-10-17",
    "Statement":[{
    "Sid":"PublicReadGetObject",
          "Effect":"Allow",
      "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::example.com/*"
        ]
      }
    ]
  }' | sed -e "s/example\.com/$name/g")" &&
  aws s3 website s3://$name/ --index-document index.html

  if [[ $isIndex ]]; then
    echo www.$name
    # aws s3api create-bucket --bucket www.$name &&
    aws s3 mb s3://www.$name &&
    aws s3api put-bucket-website --bucket www.$name --website-configuration "$(echo '{
      "RedirectAllRequestsTo": {
        "HostName": "example.com"
      }
    }' | sed -e "s/example\.com/$name/g")"
  fi
}

# create bucket if it doesn't exist
aws s3 ls | grep $name || make_bucket $name $isIndex
aws s3 sync $source s3://$name --delete
