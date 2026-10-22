
Cambiar contraseña. ejecutar CMD como administrador
```cmd
net user Matap [NUEVA CONTRASEÑA]
```

Abrir permisos GPO
```cmd
gpedit.msc
```
Consultar nombre actual
```cmd
hostname
```


Cambiar nombre del pc
```cmd
wmic computersystem where caption='nombre_actual' rename 'nuevo_nombre'
```
