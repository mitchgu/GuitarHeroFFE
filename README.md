# Guitar Hero: Fast Fourier Edition
An MIT [6.111](http://web.mit.edu/6.111/www/f2015/index.html) final project that uses a Virtex II board and a Nexys 4 (Artix-7) board to play guitar hero with real guitars.

## Requirements

### Hardware
* Two [Nexys 4](https://www.digilentinc.com/Products/Detail.cfm?Prod=NEXYS4) FPGA boards (includes an Artix-7 FPGA). One is dedicated to guitar audio processing and the other is for the rest of the game logic.

### Software
* Vivado 2015 (or similar) for Nexys 4 development.

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
* `src` contains the actual sources in three folders: `constraints`, `hdl`, and `ip`. These are fairly self-explanatory and are the core of the project.

### Documentation
The `docs` folder contains 6.111 project documentation in pdf form such as:
* Project abstract
* Project proposal draft (including block diagram)
* Project presentation
