# CLOT resources

Политика кошелька: `wallet/privacy.md`. Копия `docs/privacy.md` сохраняет существующие ссылки приложения; при изменении политики обновлять оба файла одинаково.

## Хостинг на Cherry

Публичный адрес: https://resources.clotwallet.com/wallet/privacy.md

Файл хранится в ConfigMap кластера k3s на Cherry (93.115.28.74) и раздаётся отдельным nginx в namespace `resources`. Внешний HTTPS обслуживают существующие Traefik и cert-manager (`letsencrypt-prod`). GitHub используется для исходников, GitHub Pages не используется.

DNS: `A resources.clotwallet.com → 93.115.28.74`. Не добавлять CNAME на GitHub Pages. HTTPS-сертификат выпускается после появления DNS и доступности порта 80 для ACME.

Для публикации загрузить checkout на Cherry, затем выполнить из его корня:

```sh
sh scripts/deploy-cherry.sh
```

Скрипт использует локальный `kubectl`, собирает ConfigMap из `wallet/privacy.md` и применяет `deploy/cherry`. Имя ConfigMap содержит хеш содержимого: изменение файла запускает обновление Deployment. Старые ConfigMap остаются доступными для отката; при обслуживании удалять только неиспользуемые версии.

Проверка:

```sh
kubectl -n resources get pods,ingress,certificate
curl --fail https://resources.clotwallet.com/wallet/privacy.md
```

Маршрут обслуживает только файл политики. Другие ресурсы домена этим деплоем не публикуются. Общая конфигурация ingress и существующие сервисы не изменяются.

## DNS внутри Cherry

28 октября 2026 DNS провайдера `10.100.0.53/54` возвращали NXDOMAIN для уже опубликованного домена, блокируя HTTP-01 self-check cert-manager. Для `resources.clotwallet.com` добавлен отдельный forward CoreDNS на `1.1.1.1` и `8.8.8.8` через поддерживаемый k3s ConfigMap `kube-system/coredns-custom`. Остальные зоны используют прежние DNS.

Конфигурация: `deploy/cherry/resources-dns.yaml`. Она применяется отдельно (`kubectl apply -f deploy/cherry/resources-dns.yaml`), не входит в Kustomize приложения. При существующих сторонних ключах `coredns-custom` сохранять их. После исправления DNS провайдера правило можно удалить из ConfigMap; сначала проверить ответы обоих DNS и продление сертификатов.
