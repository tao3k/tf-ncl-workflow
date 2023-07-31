let Tf = import "../../.data/tf-ncl/hello-tf/schema.ncl" in
{
  config.resource.null_resource.hello-tf-ncl = {
    provisioner.local-exec = [
      {
        command = m%"
        echo 'Hello, tf-ncl!'
        "%
      }
    ],
  },
} | Tf.Config
