variable "location" {
  type        = string
  description = "Región de Azure donde crearemos la infraestructura"
  default     = "uksouth"
}

variable "storage_account" {
  type        = string
  description = "Nombre para la storage account"
  default     = "adminnfs"
}

variable "public_key_path" {
  type        = string
  description = "Ruta para la clave pública de acceso a las instancias"
  default     = "/home/adminuser/.ssh/authorized_keys" # o la ruta correspondiente
}

variable "public_key" {
  type        = string
  description = "Clave publica"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC407KQOYQ0lzpRxw33smrlSXEg9lkwCtYPgVGM/8/j+mRjV8B6D4rC5htAbVL4Dkp6R/CR90yFBKZqr9WeLnKsm82TnvP34adry7BWmt80XA88UckKmPU1nmtkf0/bk7vQw03bABMM2lLG5MaFgUn1B4D5pd1KlGXLawiNSQJ2R3enqDlEUcJnJ8XW+7tPi2xc0mw1WXl4zCU41oEdBFOw+/qs7+7zrzPvShss/b5tBDGKS+t0fQQsB8WLhdsKoGmCONr78ShTKefB6L/s4Jfq3C0bM8KQPUFVIzGD/m72wjJyEzfU6gMAqTrQM1s00JVXsROwRcjyQ1ujV5Pk5Y1n rotten@DESKTOP-UBCCKR4" # o la ruta correspondiente
}

variable "ssh_user" {
  type        = string
  description = "Usuario para hacer ssh"
  default     = "adminuser"
}

