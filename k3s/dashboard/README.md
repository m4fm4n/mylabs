Установка dashboard для kubernetes.

1) Применить манифест recommended.yaml ( оригинал во ссылке: kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml ). Для доступа извне необходимо пропатчить service:
```
...
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort #<-- add this
  ports:
    - port: 443
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
...
```
.. далее применяем манифест:
`kubectl apply -f recommended.yaml`
2) Создать service account dashboard из манифеста:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <nameOfUser>
  namespace: kubernetes-dashboard
```
.. затем применить:
`kubectl apply -f svc-account.yaml`
3) Привязать роль к service account с помощью манифеста:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: <nameOfUser>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: <nameOfUser>
  namespace: kubernetes-dashboard
```
.. и запустить:
`kubectl apply -f cluster-role-bind.yaml`
4) Сгенерировать token для service account:
`kubectl -n kubernetes-dashboard create token <nameOfUser>`
5) Так же можно сделать "долгоживущий" token через манифест ресурса secret:
```
apiVersion: v1
kind: Secret
metadata:
  name: <nameOfUser>
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "<nameOfUser>"   
type: kubernetes.io/service-account-token
```
Далее, когда secret будет создан, выполнить команду для сохранения в secret:
`kubectl get secret <nameOfUser> -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d`
6) Доступ осуществляется по адресу node. Узнать на какой node находится pod kubernetes-dashboard:
`kubectl get pods  --all-namespaces -o wide | grep "kubernetes-dashboard-" | awk {'print $8'}`
Чтобы узнать порт, по которому доступен dashboard, необходимо выполнить команду:
`kubectl -n kubernetes-dashboard get svc/kubernetes-dashboard -o wide`
