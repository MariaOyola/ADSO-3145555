# Repositorio de la actividad 
https://github.com/MariaOyola/using-env-github-activity




## Rama padre = rama protegida, es el "ambiente oficial". Nadie escribe directamente ahí.

>- develop  → ambiente de desarrollo
>- qa       → ambiente de pruebas
>- main     → ambiente de producción


## Rama hija (HU) = rama temporal que tú creas para trabajar. Nace de su padre, hace el trabajo, y muere al mergearse.

>- HU-01-develop  → hija de develop
>- HU-01-qa       → hija de qa
>- HU-01-main     → hija de main


## MR (Merge Request) = es una solicitud formal que dices "oye, tengo cambios en mi rama hija, revísalos y únelos a la rama padre". Es el único puente permitido entre hija y padre.

( LO que tentedi )