import requests

schoolCode = input("Input school code: ")
username = input("Input your username: ")
password = input("Input your password: ")

def provisioning():
   
    url = "https://provisioning.edulinkone.com/?method=School.FromCode"
    body = "{\"jsonrpc\":\"2.0\",\"method\":\"School.FromCode\",\"params\":{\"code\":\"" + schoolCode + "\"},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
    response = requests.post(url, data=body)
    schoolServer = response.json()["result"]["school"]["server"]

    body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Login\",\"params\":{\"from_app\":false,\"ui_info\":{\"format\":2,\"version\":\"0.5.113\",\"git_sha\":\"FuckYouOvernetData\"},\"fcm_token_old\":\"none\",\"username\":\"" + username + "\",\"password\":\"" + password + "\",\"establishment_id\":2},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
    url = schoolServer + "?method=EduLink.Login"
    headers = {"Content-Type" : "application/json;charset=utf-8"}
    response = requests.post(url, data=body, headers=headers)
    print(response.json()["result"]["authtoken"])

provisioning()