SCRIPTS_DIR=./scripts

install:
	sudo bash $(SCRIPTS_DIR)/install_wg.sh

add-client:
	@read -p "Ім'я клієнта: " name; \
	sudo bash $(SCRIPTS_DIR)/add_client.sh $$name

remove-client:
	@read -p "Ім'я клієнта: " name; \
	sudo bash $(SCRIPTS_DIR)/remove_client.sh $$name

status:
	sudo wg

start:
	sudo systemctl start wg-quick@wg0

stop:
	sudo systemctl stop wg-quick@wg0

restart:
	sudo systemctl restart wg-quick@wg0

logs:
	sudo journalctl -u wg-quick@wg0 -f

backup:
	bash $(SCRIPTS_DIR)/backup.sh

restore:
	@read -p "Backup файл: " file; \
	sudo bash $(SCRIPTS_DIR)/restore.sh $$file