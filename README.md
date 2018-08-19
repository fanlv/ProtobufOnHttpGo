# 测试Protobuf在Http传输测试



## 一、编写Proto文件

	syntax = "proto3";
	
	// 生成go代码
	//protoc --go_out=. user.proto
	
	// 生成oc代码
	//protoc --objc_out=. user.proto
	
	package user;
	
	
	message LoginRequest {
	  string username = 1;
	  string password = 2;
	}
	
	message BaseResponse{
	  int64 code = 1;
	  string msg = 2;
	}
	
	
	message User{
	    string uid = 1;
	    string name = 2;
	    string logo = 3;
	}
	message LoginResponse {
	    User user = 1;
	    BaseResponse baseResp = 255;
	}

## 二、生成目标项目代码

	// cd 到user.proto文件目录
	// 生成go代码
	//protoc --go_out=. user.proto
	
	// 生成oc代码
	//protoc --objc_out=. user.proto
	
## 三、服务端测试代码


	r.POST("/login", func(c *gin.Context) {
		body, err := c.GetRawData()
		if err == nil {
			req := &user.LoginRequest{}
			err = proto.Unmarshal(body, req)
			if err == nil {
				if req.Username == "admin" && req.Password == "123456" {
					err = nil
				} else {
					err = errors.New("login fail")
				}
			} else {
				fmt.Print(err.Error())
			}
		}
		var req *user.LoginResponse
		if err == nil {
			req = &user.LoginResponse{
				User: &user.User{
					Uid:  "0010",
					Name: "admin",
					Logo: "url",
				},
				BaseResp: &user.BaseResponse{
					Code: 1,
					Msg:  "ok",
				},
			}
		} else {
			req = &user.LoginResponse{
				User: nil,
				BaseResp: &user.BaseResponse{
					Code: 100,
					Msg:  "login fail",
				},
			}
		}

		out, err := proto.Marshal(req)
		if err == nil {
			c.Data(200, "application/x-protobuf", out)
		}
	})
	
## 四、客户端测试代码

    NSDate *startDate = [NSDate date];
    LoginRequest *req = [[LoginRequest alloc] init];
    req.username = @"admin";
    req.password = @"123456";
    [self postUrl:@"http://127.0.0.1:8080/login" dataBody:[req data] Completetion:^(id result, NSError *error) {
        if (!error && [result isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)result;
            NSError *pError;
            LoginResponse *resp = [[LoginResponse alloc] initWithData:data error:&pError];
            if (!pError) {
                NSDate *endDate1 = [NSDate date];
                _infolabel.text = [NSString stringWithFormat:@"数据大小 ： %.3f KB, 请求耗时：%f",[data length]/1000.0,[endDate1 timeIntervalSinceDate:startDate]];
                _textView.text = resp.description;
            }
        }
    }];
    
## Done	