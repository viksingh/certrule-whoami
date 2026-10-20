# certrule-whoami

The smallest possible test for principal propagation from SAP BTP to an ABAP
system through the Cloud Connector. One approuter route, one ABAP ICF handler,
no own code in between. Open `/whoami` in a browser, log on to the subaccount,
and the ABAP system answers with the user the call ran as.

```
{ "abapUser": "MASSUSERTEST", "client": "001", "system": "A4H", "time": "20261019 203004" }
```

Used in the blog posts on CERTRULE instead of the gateway mapping table and on
the mass load of explicit mappings.

## Parts

| Part | What |
|---|---|
| `abap/zcl_poc_whoami.abap` | ICF handler returning sy-uname, client, system and time as JSON |
| `approuter/xs-app.json` | route `/whoami` to destination `A4H_PP`, authentication xsuaa |
| `xs-security.json` | xsuaa application without scopes, every logged on user may call |
| `manifest.yml` | cf push definition, three service bindings |

## ABAP side

1. SE24, class `ZCL_POC_WHOAMI`, source based, paste `abap/zcl_poc_whoami.abap`, activate.
2. SICF, service `zpoc_whoami` under `default_host/sap/bc`, handler list with the
   class, no logon data, activate.
3. Cloud Connector, access control for the ABAP system, resource `/sap/bc/zpoc_whoami`.

## BTP side

Prerequisites in the subaccount: trust to the identity provider, Cloud Connector
connected, and a destination `A4H_PP` with proxy type OnPremise and
authentication PrincipalPropagation pointing at the virtual host of the ABAP
system.

```
cf create-service xsuaa application whoami-xsuaa -c xs-security.json
cf create-service destination lite whoami-destination
cf create-service connectivity lite whoami-connectivity
cf push
```

`cf apps` shows the route. Open `https://<route>/whoami`.

## What to expect

- The JSON above: the certificate the Cloud Connector issued was accepted and
  CERTRULE mapped it to a user.
- A browser password popup or `401 Not authorized`: the ABAP system did not
  accept the certificate. Check `icm/trusted_reverse_proxy_0`,
  `login/certificate_mapping_rulebased` and the CERTRULE rule or mapping for the
  address you logged on with.
- `Invalid server certificate` in the Cloud Connector: the internal host does not
  match the ABAP server certificate.
