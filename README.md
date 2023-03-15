ACCESS_interview
======

愛可信面試考題

# Require
1. Use `MVVM` and `Swift`

# Method

![](./ReadMeAssets/01_Project.png)


# Demo & Remark
* Once the app has been opened, it will show the data saved in the local database. If there are no data, it will automatically fetch the first 20 users from GitHub API. <br>
![](./ReadMeAssets/02_UserList.png)

* You can click “Clear All” to wipe out all data that store in the local database. Press “Re-initial” can fetch the first 20 users again. <br>
![](./ReadMeAssets/03_UserList_empty.png)

* For the paginated function, you can keep pulling up at the bottom of the list, you will see the hint. There are three states, keep pulling up, release to fetch, and reach the fetch limit. <br>
![](./ReadMeAssets/04_UserList_pullHint.png)<br><br>
![](./ReadMeAssets/05_UserList_releaseFetch.png)<br><br>
![](./ReadMeAssets/06_UserList_reachLimit.png)

* As the requirement asked, need to show the badge if this user is a site admin. <br>
![](./ReadMeAssets/07_UserList_badge.png)

* When pressing on any user on the list, it will bring up and show all user detail that was asked in the requirement. <br>
![](./ReadMeAssets/08_UserDetail.png)

* Press on the user’s name, and it will pop up a system alert input view for the edit name requirement. <br>
![](./ReadMeAssets/09_UserDetail_editName.png)

* If click update and the name did change, it will update the database and refresh UI. <br>
![](./ReadMeAssets/10_UserDetail_nameEdited.png)
