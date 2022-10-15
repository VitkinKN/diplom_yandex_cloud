
resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 40"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "playbook" {

  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/playbook.yml"
    on_failure = continue
  }

  depends_on = [
    null_resource.wait
  ]
}
