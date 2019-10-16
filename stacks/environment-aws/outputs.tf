output "simple_output" {
  value = "hello"
}

output "test_output" {
  value = "${module.toolchain.caBundle}"
}
