//
//  ThreaterListController.swift
//  MyMovieChart
//
//  Created by 윤재웅 on 2020/10/28.
//

import UIKit
class ThreaterListController: UITableViewController {
    // API를 통해 불러온 데잉터를 저장할 배열 변수
    var list: [NSDictionary] = []
    
    // 읽어올 데이터의 시작위치
    var startPoint = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callTheaterAPI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segue_map") {
            // 선택된 셀의 행 정보
            let path = self.tableView.indexPath(for: sender as! UITableViewCell)
            
            // 선택된 셀에 사용된 데이터
            let data = self.list[path!.row]
            
            // 세그웨이가 이동할 목적지 뷰 컨트롤러 객체를 구하고, 선언된 param 변수에 데이터를 연결해준다.
            (segue.destination as? ThreaterViewController)?.param = data
        }
    
    }
    
    func callTheaterAPI() {
        // URL을 구성하기 위한 상수값을 선언
        let requestURI = "http://swiftapi.rubypaper.co.kr:2029/theater/list" // API 요청 주소
        let sList = 100 // 불러올 데이터 갯수
        let type  = "json" // 데이터 양식
        
        // 인자값들을 모아 URL 객체로 정의한다.
        let urlObj = URL(string: "\(requestURI)?s_page=\(startPoint)&s_list=\(sList)&type=\(type)")
        
        do {
            // NSString 객체를 이용하여 API를 호출하고 그 결과값을 인코딩된 문자열로 받아온다.
            // 0x80_000_422 -> EUC-KR 인코딩에 해당하는 16진수값 ( '_' - 나누기 용으로 별 상관없음)
            let stringdata = try NSString(contentsOf: urlObj!, encoding: 0x80_000_422)
            
            // 문자열로 받은 데이터를 UTF-8로 인코딩처리한 Data로 변환한다.
            let encdata = stringdata.data(using: String.Encoding.utf8.rawValue)
            
            do {
                // Data 객체를 파싱하여 NSArray 객체로 변환한다.
                let apiArray = try JSONSerialization.jsonObject(with: encdata!, options: []) as? NSArray
                
                // 읽어온 데이터를 순회하면서 self.list 배열에 추가
                for obj in apiArray! {
                    self.list.append(obj as! NSDictionary)
                }
            } catch {
                // 경고창 형식으로 오류 메시지를 표시해준다.
                let alert = UIAlertController(title: "실패", message: "데이터 분석이 실패하였습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                self.present(alert, animated: false)
            }
            // 읽어와야 할 다음 페이지의 데이터 시작 위치를 구해 저장
            self.startPoint += sList
        } catch {
            // 경고창 형식으로 오류 메시지를 표시해준다.
            let alert = UIAlertController(title: "실패", message: "데이터 분석이 실패하였습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = self.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tCell") as! ThreaterCell
        
        cell.name?.text = obj["상영관명"] as? String
        cell.addr?.text = obj["소재지도로명주소"] as? String
        cell.tel?.text = obj["연락처"] as? String
        
        return cell
    }
}
