# GitHubApp
The application supports iPhone/iPad and iOS >= 10.0 (in some places there are availability checks). Code was developed with Swift 4.0 stable version shipped with XCode 9.2.


## Notes about first part of test task.

### Common architecture

Application was developed with classical Apple Model-View-Controller approach. According to Apple MVC approach code was divided into next main parts:
1. View (table view cells, header, views)
2. View Controller (UIVIewController subclasses, also contains business logic)
3. Controller (AppDelegate)
4. Model Controller (contains data logic, networking)
5. Model (domain data classes and structures)

View, view controller, model controller and model parts are standard Apple entities (with their own responsibilities) and there are no special considerations about it but in case of model controller there are some notes.
Instead of direct creation of model controller instance in view controller, model controllers chaining or shared (singleton) instance of this class usage I applied protocol-oriented approach.
In this approach we create special protocol Repositories with default implementation (via extension) for view controllers.
Default implementation (and if view controller applies this protocol) implicity adds model controller accessor to view controller.
After that we has no problems with manually creation controller class in every view controller or complex controllers chaining support in large applications.
Also we has no connectivity problem in our project while using singleton/shared object, because this information is hidden.
This approach is very elegant Swifty solution of dependency injection problem.

### Some notes

For Repository model I used classes and not structs because of more scalability but in first part structs usage would be enough.
In some places there are Swift optional processing done via guard and calling `fataError` function (preconditions in Design by Contract terms).
It means that in this case class invariant will be violated (according to Design by Contract) and application execution can not and should not be continued (it is programming error and should be fixed before application public release while stabilization stage).
Design by contract ideas and Swift style also was applied to access control primitives (for example, `private`).
As Swift recommends, access control primitives widely used inside frameworks, but in client code there is no such strong requirement (it mainly follows from ObjC tradition where all methods are `public`).
Thats why access control primitives is used for properties and methods only with non-zero probability of class invariant violation (in case of out of class/file usage).

### GitHub API usage
To get GitHub repos I use GitHib API v3 and request `/users/:username/repos`.
I did not use Search API because of some limitations (1000 max returning instances but Google has more than 1000 repositories).
This version of application has no authorization and has limit to 60 requests per hour. Authorization is planned for next stages.
Pagination in API was implemented via GutHub link headers and recursion approaches.
Responses mapped to special Repository class via Swift `Codable` approach (with some helper methods, especially for json decoding).
Data sorting and grouping was implemented by standard Swift ways but not via GitHub API because this API has no such ability.
Repositories objects are contaned in dictionary with language name as keys and sorted respositories array as values.

### Additional notes

There is cancellability (requests cancellation) for requests if new searching begin while previous one in progress.
For localization and another strings I created constants via enums and added special helper methods.
Some errors and messages shows inside table view (via protocol-oriented approach).
If searching in progress there is also activity indicator in table view (via protocol-oriented approach).
Alerts shows also via protocol-oriented approach (see code).

### User interface

UI mainly exists in storyboards. For Repositories theres is custom table view cell and section header Table view cell has dynamic height for labels and also contains stack view.
There are some custom color and fonts in UI.

### More details

You can see more details about my implementation in application code (it contains additional documentation).

### License

Please contact me to use this code in any form.
