Для доступа к админке argocd необходимо создать ресурс ingress (ingargo.yaml). 

Кроме того, чтобы не получать ошибку 307 err_too_many_redirects, необходимо в файле install.yaml ( изменённая версия оригинала https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml ) добавить: 1) в ресурс ConfigMap argocd-cmd-params-cm:
```
data:
  server.insecure: "true"
```

2) В ресурс deployment argocd-server:
```
spec:
  template:
    spec:
      containers:
      - name: argocd-server
        args:
        - /usr/local/bin/argocd-server
      **- --insecure**
```

Далее получаем init-password для пользователя admin:
```
kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" | base64 -d; echo
```

Создать нового пользователя:

1) Добавление в ресурс cm argocd-cm данных о пользователе, путём патча ресурса:
```
kubectl get configmap argocd-cm -n argocd -o yaml > argocd-cm.yml
vim argocd-cm.yml
```
.. добавляем:
```
...
data:
  accounts.<nameOfAccount>: apiKey, login
```
.. применяем:
```
kubectl apply -f argocd-cm.yml -n argocd
``` 

2) Добавление прав новому пользователю в ресурс cm argocd-rbac-cm, путём патча ресурса:
```
kubectl get configmap argocd-rbac-cm -n argocd -o yaml > argocd-rbac-cm.yml
vim argocd-rbac-cm.yml
```
.. добавляем:
```
data:
  policy.csv: |
    g, <nameOfAccount>, role:admin
```
.. применяем:
```
kubectl apply -f argocd-rbac-cm.yml -n argocd
```

3) Создаём пароль пользователю из pod-а argocd-server:
```
kubectl -n argocd exec -it pod/argocd-server-<id> -- bash
argocd login <hostName>
```
Далее вводим данные от пользователя admin. После этого устанавливем пароль (Password should contain at least one UPPERCASE):
```
argocd account update-password --account <nameOfAccount> --new-password <PassW0rd>
```
