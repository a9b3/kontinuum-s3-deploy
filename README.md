Sync a source with a lazily created s3 bucket.

## Requirements

- requires awscli `pip install awscli`

Set these env vars in the environment that is being used to run this script.

```
AWS_DEFAULT_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### Usage

```sh
./script.sh --name foo.com --is-index <source>
```

`--name `: s3 bucket name to create

`--is-index`: is meant to be an the root domain, therefore `www.${name}` bucket will also be created

ex.

```sh
./node_modules/kontinuum-s3-deploy/script.sh --name example.com --is-index ./build
```