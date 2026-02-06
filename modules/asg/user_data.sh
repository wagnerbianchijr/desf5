#!/bin/bash

cat > index.html <<EOF
<h1>I am healthy!</h1>
<p>Deployed via Terraform</p>
EOF

nohup busybox httpd -f -p ${server_port} &