while true; do
  kubectl port-forward pod/postgress-0 5432:5432 -n postgress --address 127.0.0.1
  sleep 1
done
