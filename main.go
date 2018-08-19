package main

import (
	"fmt"
	"github.com/fanlv/ProtobufOnHttpGo/proto"
	"github.com/gin-gonic/gin"
	"github.com/golang/protobuf/proto"
	"github.com/pkg/errors"
)

func main() {
	gin.SetMode(gin.DebugMode)
	r := gin.Default()
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
	r.Run() // listen and serve on 0.0.0.0:8080
}
