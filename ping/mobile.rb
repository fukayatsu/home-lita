#! /usr/bin/env macruby

framework 'Foundation'
framework 'IOBluetooth'

#device = IOBluetoothDevice.deviceWithAddressString "xx:xx:xx:xx:xx:xx"
device = IOBluetoothDevice.deviceWithAddressString ENV['MOBILE_BLUETOOTH_ADDR']
device.openConnection(nil, withPageTimeout: 3000, authenticationRequired: false)

print !!device.isConnected

device.closeConnection