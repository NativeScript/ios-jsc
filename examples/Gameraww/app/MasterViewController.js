import fetch from './fetch';

var dateFormatter = new NSDateFormatter();
dateFormatter.locale = NSLocale.currentLocale;
//dateFormatter.dateStyle = NSDateFormatterStyle.NSDateFormatterShortStyle;
//dateFormatter.timeStyle = NSDateFormatterStyle.NSDateFormatterShortStyle;
dateFormatter.doesRelativeDateFormatting = true;

var JSMasterViewController = UITableViewController.extend(
    {
      viewDidLoad : function() {
        UITableViewController.prototype.viewDidLoad.call(this);

        this.items = [];

        this.refreshControl = new UIRefreshControl();
        this.refreshControl.addTargetActionForControlEvents(
            this, "loadData", UIControlEvents.ValueChanged);
        this.refreshControl.beginRefreshing();

        this.loadData();
      },
      "aboutPressed:" : function(sender) {
        var alertWindow = new UIAlertView({
          title : "About",
          message : "NativeScript Team",
          delegate : null,
          cancelButtonTitle : "OK",
          otherButtonTitles : null
        });
        alertWindow.show();
      },
      numberOfSectionsInTableView : function(tableView) { return 1; },
      tableViewNumberOfRowsInSection : function(tableView, section) {
        return this.items.length;
      },
      prepareForSegueSender : function(segue, sender) {
        if (segue.identifier == "showDetail") {
          var item = this.items[this.tableView.indexPathForSelectedRow.row];
          segue.destinationViewController.item = item;
        } else if (segue.identifier == "showCanvas") {
          segue.destinationViewController.items = this.items;
        }
      },
      tableViewCellForRowAtIndexPath : function(tableView, indexPath) {
        //log('tableViewCellForRowAtIndexPath');
        var cell = tableView.dequeueReusableCellWithIdentifierForIndexPath("Cell", indexPath);

        var item = this.items[indexPath.row];

        var textLabel = cell.contentView.viewWithTag(1);
        textLabel.text = item["title"];

        var created = NSDate.dateWithTimeIntervalSince1970(item["created_utc"]);
        var detailTextLabel = cell.contentView.viewWithTag(2);
        detailTextLabel.text = dateFormatter.stringFromDate(created);

        var imageView = cell.contentView.viewWithTag(3);
        fetch(item["thumbnail"])
            .then(data => UIImage.imageWithData.async(UIImage, [ data ]))
            .then(image => imageView.image = image)
            .catch(error => console.error(error.toString()));

        return cell;
      },
      tableViewHeightForRowAtIndexPath : function(tableView, indexPath) {
        return 44;
      },
      loadData : function() {
        fetch("http://www.reddit.com/r/aww.json?limit=500")
            .then(data => {
              var jsonString =
                  new NSString({data : data, encoding : NSUTF8StringEncoding});
              var json = JSON.parse(jsonString.toString());
              this.items = json.data.children.map(child => child.data);

              this.tableView.reloadData();
              this.refreshControl.endRefreshing();
            })
            .catch(error => console.error(error));
      }
    },
    {
      name : "JSMasterViewController",
      exposedMethods : {
        "loadData" : {returns : interop.types.void},
        "aboutPressed:" :
            {returns : interop.types.void, params : [ UIControl ]}
      }
    });