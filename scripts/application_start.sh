#!/bin/bash
echo "ApplicationStart iniciado: Reiniciando servicios."
sudo systemctl restart php-fpm
sudo systemctl restart httpd
echo "ApplicationStart finalizado."
