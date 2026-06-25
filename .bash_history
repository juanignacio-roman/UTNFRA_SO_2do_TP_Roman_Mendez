git clone https://github.com/upszot/UTN-FRA_SO_Examenes.git
cd UTN-FRA_SO_Examenes/
cd 202406
sudo ./script_Precondicion.sh
source ~/.bashrc
cd
mkdir -p ~/RTA_Examen_$(date +%Y%m%d)
ls
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -faSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: jammy
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
sudo apt update
sudo apt install wget gpg
UBUNTU_CODENAME=jammy
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
sudo apt update && sudo apt install ansible
ansible --version
sudo fdisk -l
sudo pvcreate /dev/sdd /dev/sdc
sudo vgcreate vg_datos /dev/sdd
sudo vgcreate vg_temp /dev/sdc
sudo lvcreate -L 5M -n lv_docker vg_datos
sudo lvcreate -L 1.5G -n lv_workareas vg_datos
sudo lvcreate -L 512M -n lv_swap vg_temp
sudo mkfs.ext4 /dev/vg_datos/lv_docker
sudo mkfs.ext4 /dev/vg_datos/lv_workareas
sudo mkswap /dev/vg_temp/lv_swap
sudo mkdir -p /var/lib/docker /work
sudo mount /dev/vg_datos/lv_docker /var/lib/docker
sudo mount /dev/vg_datos/lv_workareas /work
sudo swapon /dev/vg_temp/lv_swap
sudo systemctl restart docker
cat << 'EOF' > ~/RTA_Examen_$(date +%Y%m%d)/Punto_A.sh
sudo pvcreate /dev/sdd /dev/sdc
sudo vgcreate vg_datos /dev/sdd
sudo vgcreate vg_temp /dev/sdc
sudo lvcreate -L 5M -n lv_docker vg_datos
sudo lvcreate -L 1.5G -n lv_workareas vg_datos
sudo lvcreate -L 512M -n lv_swap vg_temp
sudo mkfs.ext4 /dev/vg_datos/lv_docker
sudo mkfs.ext4 /dev/vg_datos/lv_workareas
sudo mkswap /dev/vg_temp/lv_swap
sudo mkdir -p /var/lib/docker /work
sudo mount /dev/vg_datos/lv_docker /var/lib/docker
sudo mount /dev/vg_datos/lv_workareas /work
sudo swapon /dev/vg_temp/lv_swap
sudo systemctl restart docker
EOF

chmod +x ~/RTA_Examen_$(date +%Y%m%d)/Punto_A.sh
sudo lvs
cd
cat ~/UTN-FRA_SO_Examenes/202406/bash_script/Lista_Usuarios.txt
sudo tee /usr/local/bin/RomanAltaUser-Groups.sh << 'EOF'
if [ $# -ne 2 ]; then
    echo "Uso: $0 <Usuario_Clave_Origen> <Path_Lista_Usuarios>"
    exit 1
fi
USUARIO_ORIGEN=$1
LISTA_USUARIOS=$2
CLAVE_ENCRIPTADA=$(sudo grep "^${USUARIO_ORIGEN}:" /etc/shadow | cut -d: -f3)
while IFS=, read -r USUARIO GRUPO HOME_DIR || [ -n "$USUARIO" ]; do
    [[ "$USUARIO" =~ ^#.* ]] && continue
    [[ -z "$USUARIO" ]] && continue
    USUARIO=$(echo "$USUARIO" | tr -d ' ')
    GRUPO=$(echo "$GRUPO" | tr -d ' ')
    HOME_DIR=$(echo "$HOME_DIR" | tr -d ' ')
    if ! getent group "$GRUPO" > /dev/null; then
        sudo groupadd "$GRUPO"
        echo "Grupo creado: $GRUPO"
    fi
    if ! getent passwd "$USUARIO" > /dev/null; then
        sudo useradd -m -d "$HOME_DIR" -g "$GRUPO" -s /bin/bash "$USUARIO"
        if [ -n "$CLAVE_ENCRIPTADA" ]; then
            sudo usermod -p "$CLAVE_ENCRIPTADA" "$USUARIO"
        fi
        echo "Usuario creado: $USUARIO con Home en $HOME_DIR"
    else
        echo "El usuario $USUARIO ya existe."
    fi
done < "$LISTA_USUARIOS"
EOF

cat /usr/local/bin/RomanAltaUser-Groups.sh
sudo chmod +x /usr/local/bin/RomanAltaUser-Groups.sh
sudo /usr/local/bin/RomanAltaUser-Groups.sh vagrant ~/UTN-FRA_SO_Examenes/202406/bash_script/Lista_Usuarios.txt
cp /usr/local/bin/RomanAltaUser-Groups.sh ~/RTA_Examen_$(date +%Y%m%d)/Punto_B.sh
tail -n 5 /etc/passwd
sudo tee /usr/local/bin/RomanAltaUser-Groups.sh << 'EOF'
#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Uso: $0 <Usuario_Clave_Origen> <Path_Lista_Usuarios>"
    exit 1
fi
USUARIO_ORIGEN=$1
LISTA_USUARIOS=$2
CLAVE_ENCRIPTADA=$(sudo grep "^${USUARIO_ORIGEN}:" /etc/shadow | cut -d: -f3)
while IFS=, read -r USUARIO GRUPO HOME_DIR || [ -n "$USUARIO" ]; do
    case "$USUARIO" in
        \#*|"") continue ;;
    esac
    USUARIO=$(echo "$USUARIO" | tr -d ' ')
    GRUPO=$(echo "$GRUPO" | tr -d ' ')
    HOME_DIR=$(echo "$HOME_DIR" | tr -d ' ')
    if ! getent group "$GRUPO" > /dev/null; then
        sudo groupadd "$GRUPO"
        echo "Grupo creado: $GRUPO"
    fi
    if ! getent passwd "$USUARIO" > /dev/null; then
        sudo useradd -m -d "$HOME_DIR" -g "$GRUPO" -s /bin/bash "$USUARIO"
        if [ -n "$CLAVE_ENCRIPTADA" ]; then
            sudo usermod -p "$CLAVE_ENCRIPTADA" "$USUARIO"
        fi
        echo "Usuario creado: $USUARIO con Home en $HOME_DIR"
    else
        echo "El usuario $USUARIO ya existe."
    fi
done < "$LISTA_USUARIOS"
EOF

cp /usr/local/bin/RomanAltaUser-Groups.sh ~/RTA_Examen_$(date +%Y%m%d)/Punto_B.sh [cite: 44]
cp /usr/local/bin/RomanAltaUser-Groups.sh ~/RTA_Examen_$(date +%Y%m%d)/Punto_B.sh
sudo bash /usr/local/bin/RomanAltaUser-Groups.sh vagrant ~/UTN-FRA_SO_Examenes/202406/bash_script/Lista_Usuarios.txt
cd UTN-FRA_SO_Examenes/
cd 202406
cd docker/
ls -l
cat index.html
cat << 'EOF' > index.html
<div>
<h1> Sistemas Operativos - UTNFRA </h1></br>
<h2> 2do Parcial - Junio 2024 </h2> </br>
<h3> Juan Ignacio Román Méndez</h3>
<h3> División: 2do Programación</h3>
</div>
EOF

cat << 'EOF' > index.html
<dif>
<h1> Sistemas Operativos - UTNFRA </h1></br>
<h2> 2do Parcial - Junio 2026 </h2> </br>
<h3> Juan Ignacio Roman Mendez</h3>
<h3> Division: 116
</div>
EOF

cat << 'EOF' > index.html
<div>
<h1> Sistemas Operativos - UTNFRA </h1></br>
<h2> 2do Parcial - Junio 2026 </h2> </br>
<h3> Juan Ignacio Roman Mendez</h3>
<h3> Division: 116
</div>
EOF

cat << 'EOF' > Dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
EOF

sudo docker build -t web1-roman .
cat << 'EOF' > run.sh
#!/bin/bash
sudo docker run -d -p 8080:80 --name contenedor_web web1-roman
EOF

chmod +x run.sh
cp run.sh ~/RTA_Examen_$(date +%Y%m%d)/Punto_C.sh
sudo docker images
sudo docker login -u JuanIgnacioRomanMendez
docker login -u JuanIgnacioRomanMendez
echo "JuanIgnacioRomanMendez" | docker login -u JuanIgnacioRomanMendez --password-stdin
cd UTN-FRA_SO_Examenes/
cd 202406
cd docker/
ls -l
cat index.html 
sudo docker images
exit
cat ~/RTA_Examen_20260625/Punto_C.sh
cd UTN-FRA_SO_Examenes/
cd 202406
cd docker/
echo -e '#!/bin/bash\nsudo docker run -d -p 8080:80 --name contenedor_web JuanIgnacioRomanMendez/web1-roman:latest' > run.sh
cp run.sh ~/RTA_Examen_20260625/Punto_C.sh
cd
ls
cd RTA_Examen_20260625/
cat Punto_C.sh
cd
cd UTN-FRA_SO_Examenes/
cd 202406
ls
cd ansible/
ls -l
ls -l roles/
mkdir -p roles/2do_parcial/templates
cat << 'EOF' > roles/2do_parcial/templates/datos_alumno.txt.j2
Nombre: Juan Ignacio Apellido: Román Méndez
Division: 116
EOF

cat << 'EOF' > roles/2do_parcial/templates/datos_equipo.txt.j2
IP: {{ ansible_default_ipv4.address }}
Distribución: {{ ansible_distribution }} {{ ansible_distribution_version }}
Cantidad de Cores: {{ ansible_processor_vcpus }}
EOF

cat << 'EOF' > roles/2do_parcial/tasks/main.yml
- name: Crear estructura de directorios en /tmp/2do_parcial
  file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - /tmp/2do_parcial
    - /tmp/2do_parcial/alumno
    - /tmp/2do_parcial/equipo

- name: Generar datos_alumno.txt
  template:
    src: datos_alumno.txt.j2
    dest: /tmp/2do_parcial/alumno/datos_alumno.txt
    mode: '0644'

- name: Generar datos_equipo.txt
  template:
    src: datos_equipo.txt.j2
    dest: /tmp/2do_parcial/equipo/datos_equipo.txt
    mode: '0644'

- name: Configurar sudoers para el grupo 2PSupervisores
  become: true
  copy:
    content: "%2PSupervisores ALL=(ALL) NOPASSWD: ALL"
    dest: /etc/sudoers.d/2psupervisores
    validate: /usr/sbin/visudo -cf %s
    mode: '0440'
EOF

ansible-playbook -i inventory/hosts playbook.yml
echo -e '#!/bin/bash\nansible-playbook -i inventory/hosts playbook.yml' > ~/RTA_Examen_20260625/Punto_D.sh
chmod +x ~/RTA_Examen_20260625/Punto_D.sh
cd
cd RTA_Examen_20260625/
ls -l
cd
ls
cd UTN-FRA_SO_Examenes/
ls
cd
cd RTA_Examen_20260625/
ls
cd
ls
ls -la ~
cd carpeta_compartida/
ls
ls -l
cd
git clone https://github.com/juanignacio-roman/UTNFRA_SO_2do_TP_Roman_Mendez.git
history -a
cp ~/.bash_history ~/UTNFRA_SO_2do_TP_Roman_Mendez/.bash_history
cp -r ~/UTN-FRA_SO_Examenes/202406 ~/UTNFRA_SO_2do_TP_Roman_Mendez/
cp -r ~/RTA_Examen_20260625 ~/UTNFRA_SO_2do_TP_Roman_Mendez/
cd UTNFRA_SO_2do_TP_Roman_Mendez/
git add .
git commit -m "Entrega final de parcial - Roman Mendez"
git config --glolbal user.email "juaniiomann@gmail.com"
git config --global user.email "juaniiomann@gmail.com"
git config --global user.name "Juan Ignacio Román Méndez"
git commit -m "Entrega final de parcial - Roman Mendez"
git push origin main
tree -a -I .git
sudo apt install tree -y
tree -a -I .git
cd
sudo cp ~/RTA_Examen_20260625/Punto_B.sh /usr/local/bin/RomanAltaUser-Groups.sh
sudo chmod +x /usr/local/bin/RomanAltaUser-Groups.sh
cp ~/RTA_Examen_20260625/Punto_B.sh ~/UTNFRA_SO_2do_TP_Roman_Mendez/RTA_Examen_20260625/RomanAltaUser-Groups.sh
historu -a
history -a
cp ~/.bash_history ~/UTNFRA_SO_2do_TP_Roman_Mendez/.bash_history
cd UTNFRA_SO_2do_TP_Roman_Mendez/
git add .
git commit -m "Entrega final corregida"
git push origin main
ls
cd 202406
cd docker
docker login
docker build -t juanignacioromanmendez/web1-roman:latest .
sudo docker build -t juanignacioromanmendez/web1-roman:latest .
sudo docker push juanignacioromanmendez/web1-roman:latest
echo "docker run -d -p 8080:80 juanignacioromanmendez/web1-roman:latest" > run.sh
sudo docker login -u juanignacioromanmendez
sudo docker push juanignacioromanmendez/web1-roman:latest
echo "docker run -d -p 8080:80 juanignacioromanmendez/web1-roman:latest" > run.sh
cp run.sh ~/UTNFRA_SO_2do_TP_Roman_Mendez/RTA_Examen_20260625/Punto_C.sh
history -a
