## 1.2.1 - Customization age.
* Fix: Stop processing closed buffer
* Fix: Prevent race condition in processing buffers concurrently
* Least-recent used cache deployed (\w configurable cache slots)

## 1.2.0 - Customization age.
* Support config of included Ctags type
* Support config of statusbar priority

## 1.1.4
* Bugfix: Support classic JS function
* Bugfix: Skip processing empty buffer

## 1.1.3
* Bugfix: CompositeDisposable should not be re-used
* Included spec for testing correctness of CSS

## 1.1.2
* Bugfix: Prevent non-necessary re-run Ctags when no tag is found in the file
* Bugfix: Indentation heuristic should also end a scope with line having lower indent
* Included spec for testing correctness of Python

## 1.1.1
* Shorten the activation time
* Bugfix: Prevent toggling when the file path is undefined

## 1.1.0 - Need for speed!
* Create a scope map and use O(1) to lookup the scope
* Scope lookup is executed in each cursor row change since it's lightweight now

## 1.0.9
* CTag cache improvement
* Scope finding improvement, using a O(N) algo
* Respect Atom indentation settings

## 1.0.8
* Enhanced the mechanism that prevents continuous toggling on consecutive cursor change event

## 1.0.7
* Use Q.delay(300) to prevent continuous toggling on cursor change event

## 1.0.6
* Bug fix, show member functions in Python

## 1.0.5
* Prevent using open curly as close tag token

## 1.0.4
* Added support for Javascript

## 1.0.3
* Should ignore variable tag

## 1.0.2
* Bug fix, blank scope should be supported

## 1.0.1
* Prevent using blank line to find closed tag

## 1.0.0 - First Major Release
* Use indentation + proximity to find parent tag :)
* Still no config available yet :P
* And, bug fix in sorting the tags :P

## 0.9.1 - First Release
* It was originally 0.9.0, `apm publish` incremented the last bit.
* Finding tag using proximity, not good enough :(.
* No config available yet :P
