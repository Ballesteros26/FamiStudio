# Dn-FamiTracker Help

Change Log

Written by D.P.C.M.

Version 0.5.3.9

Last updated: 2026-05-29

---

## Unreleased - 2026-05-29

### Breaking changes

- ...

### Important changes

- ...

### Improvements

- Add more information on appearance configuration (@Nemo55aa #18)
- Clarify detail about module mixer and configuration settings (@Gumball2415 #19)

### Bug fixes

- ...

### Internal

- ...



## Release 0.5.3 - 2026-05-25

### Important changes

- Remove unused `sound.htm` page (@Gumball2415 #16)
- Explicitly mention licensing for Dn-help (@Gumball2415 #16)

### Improvements

- Reword module properties description (@Gumball2415 #16)
- Declutter and update pattern editor descriptions (@Gumball2415 #16)
- Add description of hold instrument `&&` command (@brickblock369 @Gumball2415 #14 #16)
- Add more detailed expansion audio chip images (@Gumball2415 #16)
- Link GPLv2, GPLv3, and MIT-0 license texts (@Gumball2415 #16)
- Link to DPCM pitch table in DPCM import/editor page (@Gumball2415 #16)
- Update Namco 163 information (@Gumball2415 #16)
- Add description of exponential volume in 5B instruments page (@Gumball2415 #16)

### Bug fixes

- Fix spellings of "GitHub" (@Gumball2415 #16)
- Fix and refactor table stylings (@Gumball2415 #16)
	- Sort `Exx` hardware length counter value table
	- Clarify 5B `V0x` command table

### Internal

- Move `CHANGELOG.md` to solution root folder (@Gumball2415 #15)
- Update GitHub pull request template (@Gumball2415 #15)
- Refactor HTMLHelp custom build commands (@Gumball2415 #15)
- Add change log (@Gumball2415 #15)
- Add dedicated Python script for patching template files (@Gumball2415 #9 #16)
- Update change log commit and commit format to parent repo's (@Gumball2415 #17)
- Update PR template change log format (@Gumball2415 #17)
- Add guide on parallel subrepo PRs (@Gumball2415 #17)



## Release 0.5.2 - 2026-01-06

### Important changes

- Add triangle linear counter retrigger effect description (@Gumball2415 #12)

### Improvements

- Clarify some effect descriptions (@Gumball2415 #12)

### Bug fixes

- Fix Export Wave page spelling error (@nyanpasu64 #11)

### Internal

- Implement separate changelog build command (@Gumball2415 #10)
- Refactor patch keyword to not use a comment (@Gumball2415 #10)
- Update Windows SDK version in `hlp` (@Gumball2415 Dn-Programming-Core-Management/Dn-FamiTracker#370)



## Release 0.5.1.1 - 2025-01-13

This release is made to coincide [with the 0.5.1.1 release of Dn-FamiTracker](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.5.1.1).

- Add PR template



## Release 0.5.1.0 - 2025-01-07

This release is made to coincide [with the 0.5.1.0 release of Dn-FamiTracker](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.5.1.0).

- Clarify phase reset effect description
- Add Vxx table for S5B
- Update main index, license and year
- Add groove settings, detune settings and bookmark manager to manual
- Add Dn-Help version in main index




## Release 0.5.0.2 - 2024-01-14

This release is made to coincide [with the 0.5.0.2 release of Dn-FamiTracker](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.5.0.2).

- Sync to Dn-FT repo as a submodule
- Begin to integrate markdown conversion
- Update application icon
- Generate change log page from markdown source



## Release 0.5.0.1 addenum - 2023-05-10

This release is made to provide corrections for the help manual included [in the 0.5.0.1 release of Dn-FamiTracker](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.5.0.1).

- Update .vcxproj for parity with the main project
- Rename Blue Mario to forple



## Release 0.5.0.1 - 2023-05-10

This release is made to coincide [with the 0.5.0.1 release of Dn-FamiTracker](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.5.0.1).

- Update effects list to include Nxy, Oxx, VRC7, and Sunsoft 5B effects.
- FamiTracker links now link to archived mirrors.



## Release 0.5.0.0 - 2022-12-19

This release is made to coincide [with the 0.5.0.0 release of Dn-FamiTracker](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.5.0.0).

- Update DPCM rate table to include PAL timings
- Update effects list, menu, DPCM editor, pattern editor, toolbar, control panel, NSF export info, commandline, text export, and properties pages.
- Add emulation and version configuration pages
- Update hyperlinks
- Add Kxx and =xx effects into effects list
- Add ASIC images to corresponding sound hardware pages
- Integrate 0CC-readme.txt into manual
- Clarify copyrights



## Release 0.4.0.1 - 2021-09-15

This release is made to coincide (and was released) [with the 0.4.0.1 release of Dn-FamiTracker.](https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/tag/Dn0.4.0.1)

This update simply adds the changelog information from 0.4.0.0 and 0.4.0.1 into the changelog page. No other information was altered or changed.



## 5B Information Update (Version 0.3.1.5B) - 2021-07-03

- Recoded the entire Sunsoft 5B page.
- Updated the Sunsoft 5B Documentation.
- Updated FAQ to correlate better with updated 5B information.
- Updated the Main Index with links to Github.
- Additionally updated the Sound Overview information.



## Version 0.3.1.0 - 2021-06-21

Additions

- Updated the changelog to version 0.3.1.0



## Note from Dn-FT maintainer

Before this release, Dn-help used to be part of the main repository, where it was first reimplemented at Dn0.3.0.0. Then, Dn-help became its own subrepository, where the initial commit was made on 2021-04-30, sometime after Dn0.3.0.0.
