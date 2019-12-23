# krp_druglabs
With `krp_druglabs`, you can now add more realistic roleplay to the process of producing drugs for sale or consumption.

## Requirements
- ESX
- mythic_progbar
- Any script that provides the `coke` and `meth` items

## Installation
1. Import `krp_druglabs.sql` to your FiveM database. This adds the following items:
    - Coke plant
    - Coke supplies
    - Meth supplies
2. Add this resource to your `resources` folder and `server.cfg`
3. Modify parameters in `config.lua` to your preference.

## Usage
In order to produce coke or meth, supplies must first be gathered. For coke, plant must also be harvested. Once the proper supplies have been obtained, the player must visit the drug lab for the appropriate drug. The drug lab entrance is randomly chosen from a defined list of locations each time the resource is started. Once in the drug lab, the player will need to perform a series of steps to process the drug into the final result.