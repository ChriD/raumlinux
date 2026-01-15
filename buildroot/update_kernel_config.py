
import re

config_file = '/home/dietpi/builds/buildroot/output/build/linux-6.6.64/.config'

changes = {
    'CONFIG_USB': 'y',
    'CONFIG_USB_STORAGE': 'y',
    'CONFIG_USB_XHCI_HCD': 'y',
    'CONFIG_USB_EHCI_HCD': 'y',
    'CONFIG_USB_EHCI_HCD_OMAP': 'y',
    'CONFIG_USB_OHCI_HCD': 'y',
    'CONFIG_USB_OHCI_HCD_OMAP3': 'y',
    'CONFIG_USB_OHCI_HCD_PCI': 'y',
    'CONFIG_USB_OHCI_HCD_PLATFORM': 'y'
}

with open(config_file, 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    updated = False
    for key, value in changes.items():
        if line.startswith(f'{key}=') or line.startswith(f'# {key} is not set'):
            new_lines.append(f'{key}={value}\n')
            updated = True
            break
    if not updated:
        new_lines.append(line)

with open(config_file, 'w') as f:
    f.writelines(new_lines)

print("Config updated.")
