package main

import (
	"bytes"
	"fmt"
	"net/smtp"
	"strings"
	"text/template"
	"time"
	"os"
)

/**
 * user : example@example.com login smtp server user
 * password : xxxxx login smtp server password
 * host : smtp.example.com:port smtp.163.com:25
 * to : example@example.com;example1@163.com;example2@sina.com.cn;...
 * subject : The subject of mail
 * body : The content of mail
 * mailtyoe : mail type html or text
**/
func send(to, subject, body, mailtype string) error {
	user := "wizarddewhite@gmail.com"
	password := "1410813025"
	host := "smtp.gmail.com:587"

	hp := strings.Split(host, ":")
	auth := smtp.PlainAuth("", user, password, hp[0])
	var content_type string
	if mailtype == "html" {
		content_type = "Content-Type: text/" + mailtype + "; charset=UTF-8"
	} else {
		content_type = "Content-Type: text/plain" + "; charset=UTF-8"
	}

	msg := "From: Shlug <wizarddewhite@gmail.com> \n" +
		"To: " + to + "\n" +
		content_type + "\n" +
		"Subject: " + subject + "\n\n" +
		body
	send_to := strings.Split(to, ";")
	err := smtp.SendMail(host, auth, user, send_to, []byte(msg))
	return err
}

type ConfimrMail struct {
	Name string
	Hash string
}

func next4() string {
	now := time.Now()
	weekday := int(now.Weekday())
	n4 := now.AddDate(0, 0, 4-weekday)
	return n4.Format("2006/01/02")
}

func H4Notify(uname, to, hash string) {
	check_res := "0"
	if len(os.Args) == 2 {
		check_res = os.Args[1]
	}
	reason := ""
	switch check_res {
	case "1":
		reason = "因为其他原因"
	case "2":
		reason = "欢度假期"
	}
	Templ := ``
	if reason != "" {
		Templ += reason +
`，本期活动取消。

有关Hacking Thursday活动的介绍：
http://www.shlug.org/about/#hacking-thursday

SHLUG的新浪微博地址：http://weibo.com/shanghailug 有每次活动照片以及信息发布
`

	} else {
		Templ += `
店名：JAcafe花园咖啡
点评：http://www.dianping.com/shop/2019466
地址：静安区南京西路1649号静安公园内(近静安公园)
走法：地铁2号线静安寺站，5号口出来，下沉式广场东边上来，直走即可（最近5号口封闭，需要从无障碍电梯走）。
内容：没有演讲主题,自由交流
时间：一般19：00~22：00
消费：随意

有任何想学习或者愿意分享的内容，可以回复本帖，让大家事先做好准备。

有关Hacking Thursday活动的介绍：
http://www.shlug.org/about/#hacking-thursday

SHLUG的新浪微博地址：http://weibo.com/shanghailug 有每次活动照片以及信息发布
`
	}
	fmt.Println(Templ)

	var body bytes.Buffer
	t, _ := template.New("cm").Parse(Templ)
	t.Execute(&body, &ConfimrMail{uname, hash})
	if reason != "" {
		send(to, next4()+" 暂停本周Hacking Thursday Night活动", body.String(), "text")
	} else {
		send(to, next4()+" 吃吃喝喝Hacking Thursday Night聚餐活动 at JAcafe花园咖啡", body.String(), "text")
	}
}

func main() {
	H4Notify("a", "shlug@googlegroups.com", "abc")
}
