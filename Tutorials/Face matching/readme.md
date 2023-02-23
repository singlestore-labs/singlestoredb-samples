# **Image Matching in SQL with SingleStoreDB**

In this example, we’ll demonstrate how we use the dot_product function (for cosine similarity) to find a matching image of a celebrity from among 7000 records in just 3 milliseconds! Vector functions in SingleStoreDB make it possible to solve AI problems, including face matching, product photo matching, object recognition, text similarity matching and sentiment analysis.

For additional details about it, check our [blog post.](https://www.singlestore.com/blog/using-vector-functions-image-matching-sql/)

**Step 1**: Signup for a free trial account at https://portal.singlestore.com/ 

**Step 2**: Create a workspace (S00 is enough).

**Step 3**: Create a database called image_recognition in the SQL Editor

```Create database image_recognition; ```

**Step 4**: Go to ‘connect’ on your workspace in the portal and copy the workspace URL, your username and password to connect to your database using sqlalchemy. 

![Connect](https://user-images.githubusercontent.com/8846480/219804159-9a970958-6beb-4b96-9497-20418dbe6801.png)

**Step 5**: Use the notebook face_recognition.ipynb in this repository

:exclamation: The notebook runs each command from a SQL script stored in Github and might take 15-20 minutes to be executed The notebook will run thousands of commands sequentially from the SQL script stored in Github repo and might take 15-20 minutes to be fully executed.

:exclamation: Make sure to change the following variables to your workspace:

```
UserName='<Username usually admin>'
Password='<Password for that user>'
DatabaseName='image_recognition'
URL='<Host that you copied above>:3306'
```
