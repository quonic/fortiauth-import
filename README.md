# FortiAuth-Import

FortiAuth-Import is a solution to a FortiAuth appliance failing to provide a decent user import functionality. I couldn't find any other tool that does this in any capacity.

Some of the advantages when using this script, listed below:

* Returning all possible issues with an import file, i.e. not stopping on the first error
* Reduce the time it takes to import 1000's of users from hours to a few minutes
* Unassigning tokens from existing users for new users
* Ability to update existing users with a new token
* Ability to use this to automate importing users, i.e. watching a folder for new csv files

## Development Install

```
git clone https://github.com/quonic/fortiauth-import.git
cd fortiauth-import
```
<!--
# Install

- [ ] Add to PSGallery
```
Install-Module -Name FortinetImporter -Scope CurrentUser
```
-->

## References

API reference: [Fortinet Authenticator REST API v4.0 Documentation](http://docs.fortinet.com/uploaded/files/2596/FortiAuthenticator%204.0%20REST%20API%20Solution%20Guide.pdf)

## GitPitch PitchMe presentation

* [gitpitch.com/quonic/FortiAuth-Import](https://gitpitch.com/quonic/FortiAuth-Import)

## Getting Started

Install from the PSGallery and Import the module

    Install-Module FortiAuth-Import
    Import-Module FortiAuth-Import


## More Information

For more information

* [FortiAuth-Import.readthedocs.io](http://FortiAuth-Import.readthedocs.io)
* [github.com/quonic/FortiAuth-Import](https://github.com/quonic/FortiAuth-Import)
* [quonic.github.io](https://quonic.github.io)


This project was generated using [Kevin Marquette](http://kevinmarquette.github.io)'s [Full Module Plaster Template](https://github.com/KevinMarquette/PlasterTemplates/tree/master/FullModuleTemplate).
