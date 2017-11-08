import frida

session = frida.attach("DingTalk.exe")

print([x.name for x in session.enumerate_modules()])

session.detach()
