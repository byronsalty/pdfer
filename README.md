# PDFer

This project started as following [this article on Medium by <author>](link?), but evolved to add Docker to resolve the sticky issue of system dependencies to do full generations. Things like making sure you have headless_chrome installed and configured correctly.

This is not intended to be an exhaustive list of capabilities possible, take a look at the [PDF Generator docs](https://link.link)

## Setup

The beauty of this setup is that everything happens through Docker so your only dependencies are installing Docker and then being able to run the attached shell scripts.

1. Install Docker
2. That's it!

## Build locally and run

Run the following command
```
./build.sh
./run.sh
```

## Or use pre-built image to run

Alternatively you could skip this phase and just use the Docker image I've published.

```
./run-prebuilt.sh
```


## Use

This simple app will create an Elixir Phoenix endpoint `/pdf` that will accept a `url` parameter which will be the URL of the website that you want to turn into PDF. This parameter must be URL encoded.

Now you can generate a pdf [`localhost:4000`](http://localhost:4000/pdf?url=http%3A%2F%2Fwikipedia.org%2F) from your browser.


## Use as a Service

If you don't want to build/host your own version of these service, and/or get any additional features added, then you can use the little service I'm setting up here:

[Salty PDF](https://salty-pdf.fly.dev/pdf?url=http%3A%2F%2Fwikipedia.org%2F)

In this case, you will need to create an account and attach a bearer-token to the request for tracking purposes. This service will be free to a low amount of usage.


## Works used

  * PDF Generator: https://www.phoenixframework.org/
