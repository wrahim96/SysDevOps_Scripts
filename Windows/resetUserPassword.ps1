Set-ADAccountPassword `
    -Identity "jdoe" `
    -NewPassword (ConvertTo-SecureString "NewP@ssw0rd" -AsPlainText -Force) `
    -Reset