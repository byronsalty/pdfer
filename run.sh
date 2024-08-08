secret_key=$(mix phx.gen.secret)
echo "key = $secret_key"
docker run -it --rm -p 4000:4000 -e SECRET_KEY_BASE=$secret_key pdf-base

