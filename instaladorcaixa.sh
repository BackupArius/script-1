#!/bin/bash

#################################################
# Script Instalador Geral
# Data: 25/03/2022
# Autor: Cleber e Kelberson
################################################

pacote=$(dpkg --get-selections | grep dialog)

if [ "$pacote" ] ; then
	echo "Pacote $programa já instalado."
else
	sudo sudo apt-get update
	sudo apt-get install bc nmap curl netcat dialog -y
fi

opcao=$( dialog --stdout --backtitle "Instalador Geral" --menu "Escolha sua Opcao" 15 45 25 \
1 "Instalar VPN Slackware" \
2 "Instalar VPN Ubuntu" \
3 "Instalar VNC Ubuntu" \
4 "Instalar Backup" )

case $opcao in
0)
		clear
		echo "Programa terminado."
	;;
1)
	nserver=$(grep "8.8.8.8" /etc/resolv.conf)
	
	if [ "$nserver" ]; then
	sleep 2
	else
		echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && /etc/rc.d/rc.inet1 restart
	fi
	ln -sf /usr/local/lib/libcrypto.so.1.0.0  /usr/lib/libcrypto.so.1
	ln -sf /usr/local/lib/libssl.so.1.0.0  /usr/lib/libssl.so.1 
	cd /root
	
	removepkg glibc-2.17-i486-7.txz
	removepkg nc-1.10-i386-1.txz
	removepkg wnbtlscli-1.0.1x-i486.tgz
	removepkg curl-7.55.0-i486-1_slack13.0.txz
	rm /var/log/wnb/ -R
	rm /etc/wnbtlscli/ -R
	rm /etc/wnbtlscli/registry
	rm /usr/bin/wnbmonitor

	pack="/root/conectpack.zip"
	
	if [ "$pack" ]; then
		sleep 2
	else
		cd /root
		
		wget https://github.com/cleberfmiguel/script/blob/44f6b31d217b36b10f53e3a990e12e338d56e6bd/conectpack.zip && unzip conectpack.zip
		
		cp /root/wnbmonitor.slack /usr/bin/wnbmonitor && chmod 777 /usr/bin/wnbmonitor
		
		(installpkg curl-*.txz) | dialog --stdout --title 'Instalação dos Pacotes' --guage '\ncurl-7.55.0-i486-1_slack13.0.txz...' 8 40 60
		(installpkg glibc-*.txz) | dialog --stdout --title 'Instalação dos Pacotes' --guage '\nglibc-2.17-i486-7.txz...' 8 40 60
		(installpkg nc-*.txz) | dialog --stdout --title 'Instalação dos Pacotes' --guage '\nnc-1.10-i386-1.txz...' 8 40 60
		(installpkg wnbtlscli*.tgz) | dialog --stdout --title 'Instalação dos Pacotes' --guage '\nwnbtlscli_1.0.1-i486.tgz...' 8 40 60
	fi

	wnbmonlocal=$(grep "wnbmonitor" /etc/rc.d/rc.local)
	if [ "$wnbmonlocal" ]; then
		sleep 2
	else
		echo 'wnbmonitor -s' >> /etc/rc.d/rc.local
	fi

	wnbtlslocal=$(grep "wnbtlscli" /etc/rc.d/rc.local)
	if ["$wnbtlslocal" ]; then
		sleep 2
	else
		echo 'wnbtlscli &'	>> /etc/rc.d/rc.local
	fi

	chave=$( dialog --stdout --inputbox "Digite a Chave" 8 40 )
	wnbmonitor -k $chave
	wnbmonitor -s
	wnbtlscli &
	dialog --stdout --title "Sucesso" --infobox "Instalação Finalizada com Sucesso." 4 40
	;;
2)
	packdeb=`uname -m`
	nserver=$(grep "8.8.8.8" /etc/resolvconf/resolv.conf.d/head)

	if [ "$nserver" ]; then
		sleep 2
	else
-		echo 'nameserver 8.8.8.8' >> /etc/resolvconf/resolv.conf.d/head	
	fi

	cd /root

	if [ "$packdeb" = "i686" ]; then
		
		rm wnbtlscli_1.0.3-i386*
		wget ftp://cre:suporte@ftp.cre.com.br:2321/pub/cre/conect/ubuntu/wnbtlscli_1.0.3-i386.deb
		dpkg -i wnbtlscli_1.0.3-i386.deb
	else
		rm wnbtlscli_1.0.3-amd64*
		wget ftp://cre:suporte@ftp.cre.com.br:2321/pub/cre/conect/ubuntu/wnbtlscli_1.0.3-amd64.deb
		dpkg -i wnbtlscli_1.0.3-amd64.deb
	fi
	chave=$( dialog --stdout --inputbox "Digite a Chave" 8 40 )
	wnbmonitor -k $chave
	dialog --stdout --title "Sucesso" --infobox "Instalação Finalizada com Sucesso." 4 40
	;;
3)
	sudo apt-get -f install -y
	sudo apt-get install x11vnc -y 
	senha=$( dialog --stdout --inputbox "Digite uma Senha para o VNC" 8 40 )
	sudo x11vnc -storepasswd $senha /etc/x11vnc.pass
	sudo touch /etc/systemd/system/x11vnc.service
		echo '#Inicio' >>  /etc/systemd/system/x11vnc.service
		echo '[Unit]' >>  /etc/systemd/system/x11vnc.service
		echo 'Description="x11vnc"' >>  /etc/systemd/system/x11vnc.service
		echo 'Requires=display-manager.service' >>  /etc/systemd/system/x11vnc.service
		echo 'After=display-manager.service' >>  /etc/systemd/system/x11vnc.service
		echo '[Service]' >>  /etc/systemd/system/x11vnc.service
		echo 'ExecStart=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth /etc/x11vnc.pass' >>  /etc/systemd/system/x11vnc.service 
		echo 'ExecStop=/usr/bin/killall x11vnc' >>  /etc/systemd/system/x11vnc.service
		echo 'Restart=on-failure' >>  /etc/systemd/system/x11vnc.service
		echo 'Restart-sec=2' >>  /etc/systemd/system/x11vnc.service
		echo '[Install]' >>  /etc/systemd/system/x11vnc.service
		echo 'WantedBy=multi-user.target' >>  /etc/systemd/system/x11vnc.service
		echo '#Fim' >>  /etc/systemd/system/x11vnc.service
	sudo systemctl daemon-reload
	sudo systemctl start x11vnc
	sudo systemctl enable x11vnc
	dialog --stdout --title "Sucesso" --infobox "Instalação Finalizada com Sucesso." 4 40
	;;
4)
DIA_ATUAL=`date --date="-0 day" +"%Y.%m.%d"`
HORAINICIAL=`date +%T`
VER=$(lsb_release -r| awk ' {print substr ($2,0,5) } ')
IPV4=$(cat /etc/network/interfaces | grep "address"|cut -c8-)
UPTIME=$(uptime -s)

####################################################
# Entrada do nro da loja e cliente
	clear
		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Coletando informações do Cliente"
		echo "----------------------------------------------------------------------"
		echo "Insira o nome do cliente em minúsculo e sem espaços em branco"
		echo "Exemplos: bombaiano, souzabueno, jdbrasilia, tateno_delihouse, teddy..."
		echo "Qual o Nome do Cliente"
    		read CLIENTE;
		echo "Qual o Numero da Loja. Ex. loja01"
    		read LOJA1;
	clear
		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Confira as infomações do cliente" 
		echo "Nome do Cliente: ${CLIENTE}"
		echo "Loja: ${LOJA1}"
		echo "Estão corretas? Responda s/n e tecle Enter."
    		read CONFIRME;

## Solicitando a confirmação das infomações
if [ ${CONFIRME} == n ]; then
	clear
	echo "............ Reinicie o Processo ................"
	echo "............. Execute novamente o Script ./criabkp.sh ................"
	exit 0
else
	clear
	echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Continuando a instalação"
	echo -n "Coletando informações.." && sleep 3
	echo "Ubuntu ${VER}" && sleep 2
	echo "IP ${IPV4}" && sleep 1
	echo -n "Processador  "
	cat /proc/cpuinfo | grep -m1 "model name"|cut -c14- && sleep 2
	echo "Máquina Ativa desde :   ${UPTIME}" && sleep 2
	echo "Espaço em Disco:"
	df -h | egrep -v '(tmpfs|udev)' && sleep 8
fi

	clear
		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Criando Diretorios"
		mkdir -p /u01/backup/${CLIENTE}/${LOJA1}/licenca
		ls -R /u01 && sleep 5

######################################################
# Instala o rclone
	clear
		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Instalando o RClone" && sleep 3
if [ -f /usr/bin/rclone ]; then
		echo "============ Continuando a instalação do Backup ==========" && sleep 5
else
	curl https://rclone.org/install.sh | sudo bash
fi

	clear
		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Configurando o RClone"
		wget -c ftp://cre:suporte@ftp.cre.com.br:2321/pub/cre/kelberson/rclone.conf && mkdir -p /root/.config/rclone/
		cp -vf rclone.conf /root/.config/rclone/ && cat /root/.config/rclone/rclone.conf && sleep 5

###########################################
# Cria o arquivo de bkpgeral.sh
	clear
		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Criando Arquivos " && sleep 3
		rm -f /u01/bkpgeral.sh
		touch /u01/bkpgeral.sh && cd /u01/
			echo '#################################################' >> bkpgeral.sh
			echo '# Script da Backup e envio de arquivos para o FTP CRE' >> bkpgeral.sh
			echo '# Data: 27/02/2019' >> bkpgeral.sh
    		echo '# Autores / Cleber / Jasiel / Kelberson' >> bkpgeral.sh
    		echo '################################################' >> bkpgeral.sh
    		echo '#' >> bkpgeral.sh
    		echo '#' >> bkpgeral.sh
    		echo '#### Variaveis de datas' >> bkpgeral.sh
    		echo 'DIA_ATUAL=`date --date="-0 day" +"%Y.%m.%d"`' >> bkpgeral.sh
    		echo 'BKP_OLD=`date --date="-5 day" +"%Y.%m.%d"`' >> bkpgeral.sh
    		echo '#' >> bkpgeral.sh
    		echo '#' >> bkpgeral.sh
    		echo '#### Configuracoes do Cliente' >> bkpgeral.sh
    		echo 'EMPRESA="'${CLIENTE}'"' >> bkpgeral.sh
    		echo 'LOJA="'${LOJA1}'"' >> bkpgeral.sh
    		echo 'DIR_BKP="/u01/backup"' >> bkpgeral.sh
    		echo 'DIR_BKP2=/u01/backup/${EMPRESA}/${LOJA}' >> bkpgeral.sh

		wget -c ftp://cre:suporte@ftp.cre.com.br:2321/pub/cre/kelberson/install_bkp
		cat install_bkp >> /u01/bkpgeral.sh
		rm -vf /u01/install_bkp*

#########################################################
# Insere a linha nos Crontabs
clear
	echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Agendando Tarefa de Backup no Crontab" && sleep 3
		CRON=$(grep "bkpgeral.sh" /etc/crontab)
			if [ -n "$CRON" ]; then
				echo "=========== O agendamento ja existe ==============="
				echo "=========== Continuando a instalação do Backup ===============" && sleep 5
			else
				echo '30 2	* * *	root	/u01/./bkpgeral.sh' >> /etc/crontab
				service cron restart
			fi
			tail /etc/crontab && sleep 3

#########################################################
# Insere a linha no samba
clear
	echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Criando compartilhamento no Samba" && sleep 3
		SMB=$(grep "/u01/backup" /etc/samba/smb.conf)

			if [ -n "${SMB}" ]; then
				echo "================= A configuracao Samba ja existe ===================="
				echo "================Continuando a instalação do Backup=====================" && sleep 5
			else
				echo '#' >> /etc/samba/smb.conf
				echo '[backup]' >> /etc/samba/smb.conf
				echo '	path = /u01/backup' >> /etc/samba/smb.conf
				echo '	writable = yes' >> /etc/samba/smb.conf
				echo '	public = yes' >> /etc/samba/smb.conf
				echo '	printable = no' >> /etc/samba/smb.conf
				echo '	create mask = 0666' >> /etc/samba/smb.conf
				echo '	directory mask = 0777' >> /etc/samba/smb.conf
				service smbd restart
			fi

clear
	echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Executando backup pela primeira vez" && sleep 3
		chmod +x /u01/bkpgeral.sh && clear
		echo "Deseja instalar o atualizador automatico de Licencas?"
		echo "Digite 1 para NÃO"
		echo "Digite 2 para SIM"
		read confirma2;

			if [ ${confirma2} == 2 ]; then
				echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Iniciando a instalação do EMK Licenca 2.2"
				wget -c ftp://cre:suporte@ftp.cre.com.br:2321/pub/cre/kelberson/emk_licenca.2.2.deb
				dpkg -i emk_licenca.2.2.deb
				rm -vf /u01/emk_licenca.2.2.deb
			else
				echo "================= EMK Licenca 2.2 nao sera instalada ==================="
				echo "================= Continuando a instalação do Backup ==================="
			fi

		echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Tarefa de Backup criada"
		echo -n "..." && sleep 3
		echo -n "...." && sleep 3
		echo "Com sussesso" && sleep 3
		clear

## script para calcular o tempo gasto no processo de backup
	HORAFINAL=`date +%T`
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	echo [$(date --date="-0 day" +"%d/%m-%H:%M:%S")]".....Finalizando $0 "
	echo "================= Tempo total gasto na execução $TEMPO ================="
;;
esac
