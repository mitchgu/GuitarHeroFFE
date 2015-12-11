# Guitar Hero: Fast Fourier Edition
An MIT [6.111](http://web.mit.edu/6.111/www/f2015/index.html) final project that uses a Virtex II board and a Nexys 4 (Artix-7) board to play guitar hero with real guitars.

## Requirements

### Hardware
* Two [Nexys 4](https://www.digilentinc.com/Products/Detail.cfm?Prod=NEXYS4) FPGA boards (includes an Artix-7 FPGA). One is dedicated to guitar audio processing and the other is for the rest of the game logic.
* Assorted resistors and a headphone jack to setup a 0.5V bias for the guitar's pickup signal to be input into the XADC Header

### Software
* Vivado 2015.4 or later for Nexys 4 development.

### Peripherals
* An electric guitar and amp
* A 1/4" mono male to male guitar cable and jack
* A VGA monitor to display the game
* A SD card no greater than 4GB to load song data

## Organization
The repository has two main parts: the Nexys4Guitar part which houses the guitar audio processing project and the Nexys4Game part which contains the rest of the game.

In each part, there may be 3 folders:
* `bin` contains the latest working bitstream file that can be directly programmed onto an FPGA
* `proj` contains Vivado project folder. Most of the project files are actually ignored through .gitignore, but the project file should remain
* `src` contains the actual sources in several folders for constraints, hdl, coefficient/mif files, ip configuration, and block designs. These are fairly self-explanatory and are the core of the project.

In the graphics folder, there are original image assets for the background and fret sprites.

In the SD dumps folder, there are original hex dumps (4 for each of 48 notes/chords) of reference spectra read from the SD card.

In the scripts folder, there are various python scripts that were used for COE and MIF file generation, SD card reading, image processing, and printing repetitive blocks of Verilog code.

## Assembling the project from scratch
The procedure is roughly as follows for either the Nexys4Game or Nexys4Guitar part:

1. Create a new Vivado project in the proj directory.
2. Add all the hdl in src/hdl to the project
3. Add all test benches in src/test to the project
4. Add all the ips in src/ip to the project
5. Add all block designs (if any) in src/bd to the project
6. Ensure that all block ram ips that have a corresponding coe file in the src/coe directory are correctly linked to that coe file (this is done in the IP configuration window). This is most applicable to the Nexys4Game project. The bg_run_table coe may take several minutes to validate.
7. Add all constraints in src/constraints to the project
8. Cross your fingers and synthesize/implement/write bitstream

Note: For the Nexys4Guitar project, Vivado will likely complain that "Complex defparams are not supported." In that case, entering the following in the TCL console will allow complex defparams: `set_param synth.elaboration.rodinMoreOptions "rt::set_parameter allowIndexedDefparam true"`

### Documentation
The `docs` folder contains 6.111 project documentation in pdf form such as:
* Project abstract
* Project proposal draft (including block diagram)
* Project presentation
