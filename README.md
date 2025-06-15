# Principe du system-tree

Salut à toi cypber visiteur qui lit cette modeste doc…  
J'espère que tu trouveras ici de quoi assouvir ta soif de connaissance
sur le concept abstrait mais ho combien pratique du, pour l'instant,
nébuleux `system-tree`.

Imaginons un répertoire `/system-tree/tree` qui représente un
**extrait** du système complet qu'est la racine universelle `/`.  
L'idée du `system-tree` est que tout ce qui se trouve dans
le répertoire `/system-tree/tree` doit se retrouver dans `/` sous
forme de liens symboliques.

Par exemple, dans `/system-tree/tree` on pourrait avoir cette arborescence :

```txt
.
├── etc
│   ├── apache2
│   │   ├── apache2.conf
│   │   ├── cert
│   │   ├── conf-available
│   │   ├── conf.d
│   │   ├── conf-enabled
│   │   ├── envvars
│   │   ├── magic
│   │   ├── mods-available
│   │   ├── mods-enabled
│   │   ├── password
│   │   ├── ports.conf
│   │   ├── sites-available
│   │   └── sites-enabled
│   ├── letsencrypt
│   │   ├── accounts
│   │   ├── archive
│   │   ├── cli.ini
│   │   ├── csr
│   │   ├── keys
│   │   ├── live
│   │   ├── options-ssl-apache.conf
│   │   ├── renewal
│   │   └── renewal-hooks
│   └── yapbck.conf
└── usr
    └── local
        ├── bin
        └── src
```

et le script `exemple.sh` créera les liens symboliques :

* `/etc/apache2` vers `system-tree/tree/etc/apache2`
* `/etc/letsencrypt` vers `system-tree/tree/etc/letsencrypt`
* `/etc/yapbck.conf` vers `system-tree/tree/etc/yapbck.conf`
* `/usr/local/bin` vers `system-tree/tree/usr/local/bin`
* `/usr/local/src` vers `system-tree/tree/usr/local/src`

Le but ultime et honnêtement avoué de la structure `system-tree` est de
centraliser toute **la configuration nécessaire, et seulement celle nécessaire,**
du serveur en un seul endroit afin de pouvoir facilement la
réinstaller sur un autre serveur.

# Utilisation et maintenance

Tu auras saisi que, comme expliqué dans le paragraphe précédent si
perspicace padawan tu es, c'est le script `system-tree.sh` qui sait
créer les bons liens symboliques de l'espace `/system-tree/tree` (par
défaut) dans l'univers `/`.

Le script `system-tree.sh` n'est donc qu'une bibliothèque de fonctions
*bash* utiles pour mettre à jour à la fois le `system-tree` et le
répertoire racine du serveur.

Ainsi, chaque serveur aura sont propre script d'installation et de
maintenance s'appuyant sur la lib `system-tree.sh` et sont répertoire
dédié `/system-tree/tree`.

Cette méthode DIY.fr ©PI a le désavantage de devoir être très
rigoureux sur la maintenance du serveur car il faut s'assurer que
toute nouvelle configuration apportée est bien reportée dans le
génialissime `system-tree`.

Ainsi, la création ou la modification de **nouveaux** fichiers qui ne
sont pas dans le `system-tree` doivent avant tout se faire dans le
`system-tree` avec modification éventuel du script
d'installation/configuration de ton serveur pour qu'il sache quoi en faire.

# API

La fonction **FONDAMENTALE** du `system-tree` est la fonction
`symlinck` qui admet un et un seul paramètre : un chemin vers un
fichier ou un répertoire.  
Elle effectue les actions suivantes :
1. déplace automatiquement le répertoire ou fichier spécifié en
   argument dans le répertoire `/system-tree/tree` **s'il n'y existe
   pas déjà**
2. si la ressource existe à la fois dans l'arborescence relative à `/`
   et dans celle relative à `/system-tree/tree`, effectue un backup de la
   ressource relative à `/`.
3. crée le lien symbolique relativement au répertoire racine du
   serveur vers la ressource spécifiée se trouvant dans le
   `/system-tree/tree`.

D'autres fonctions « utiles » existent dans la lib, comme, en vrac
`symlinck_usr_local`, `symlinck_home`, `symlinck_cron`,
`symlinck_systemd`, `install_node`, etc ; je laisse au lecteur le soin
de les étudier/comprendre directement dans le code source de la lib,
elles sont assez basiques.

# Mise en garde

Le script d'installation de ton serveur doit impérativement pouvoir
être exécuté autant de fois que nécessaire.  
Il est donc **FORTEMENT recommandé** de l'exécuter pour ajouter toutes nouveautés
plutôt que de les ajouter à la main et de modifier le script après coup.  
Cela garantira le bon fonctionnement du script et les inévitables
zerreurs de saisie.
