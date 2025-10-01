import asyncio
from bleak import BleakClient, BleakScanner
from bleak.backends.characteristic import BleakGATTCharacteristic
import serial

# %新板子（绿灯）
# app.bluetooth_F170A479AA6A = ble("FBE9B9A336B0")
# %旧板子（红灯）
# %app.bluetooth_F170A479AA6A = ble("FBB886F5A936")
#par_device_addr = "FB:E9:B9:A3:36:B0"
# par_notification_characteristic = "0000fff1-0000-1000-8000-00805f9b34fb"
par_device_addr  ="D9:0B:40:EA:A4:64"
par_notification_characteristic = "0000fff1-0000-1000-8000-00805f9b34fb"
ser = serial.Serial('COM100',115200)

def notification_handler(characteristic: BleakGATTCharacteristic, data: bytearray):
    # print("receivied data:", [int(data_1) for data_1 in data])
    ser.write(data)


async def main():
    print("start scan...")

    device = await BleakScanner.find_device_by_address(par_device_addr, cb=dict(use_bdaddr=False))

    if device == None:
        print("could not find device with address: ", par_device_addr)
        return
    disconnected_event = asyncio.Event()

    def disconnected_callback(client):
        print("Disconnect callback called!")
        ser.close()
        disconnected_event.set()

    print("connecting...")

    async with BleakClient(device,disconnected_callback=disconnected_callback) as client:
        print("Connected")
        await client.start_notify(par_notification_characteristic, notification_handler)
        await disconnected_event.wait()
        # await asyncio.sleep(10.0)
        # await client.stop_notify(par_notification_characteristic)
        
asyncio.run(main())