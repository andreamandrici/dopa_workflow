bckps in /spatial_data/backups/...

-  pg_dump -h s-jrciprap247p.jrc.it -d wolfe -p 5432 -U h05ibex -n protected_sites -Fc -v -f protected_sites.dump > protected_sites_backup.log 2>&1
-  pg_restore -l protected_sites.dump >/dev/null 2>&1 && echo "OK: dump complete" || echo "ERROR: dump corrupted"
-  pg_restore -h s-jrciprap247p.jrc.it -d wolfe -p 5433 -U h05ibex --verbose protected_sites.dump > protected_sites_restore.log  2>&1
