//
//  ALKFormCell.swift
//  ApplozicSwift
//
//  Created by Mukesh on 08/07/20.
//

import Applozic
import UIKit

class ALKFormCell: ALKChatBaseCell<ALKMessageViewModel>, UITextFieldDelegate {
    public var tapped: ((_ index: Int, _ name: String, _ formDataSubmit: FormDataSubmit?) -> Void)?
    let itemListView = NestedCellTableView()
    var submitButton: CurvedImageButton?
    var identifier: String?
    var activeTextField: UITextField? {
        didSet {
            activeTextFieldChanged?(activeTextField)
        }
    }

    var activeTextFieldChanged: ((UITextField?) -> Void)?
    var formDataCacheStore = ALKFormDataCache.shared

    var formData: FormDataSubmit? {
        get {
            guard let key = identifier else {
                return nil
            }
            return formDataCacheStore.getFormDataWithDefaultObject(for: key)
        }
        set(newFormData) {
            guard let key = identifier,
                let formData = newFormData else { return }
            formDataCacheStore.set(formData, for: key)
        }
    }

    private var items: [FormViewModelItem] = []
    private var template: FormTemplate? {
        didSet {
            items = template?.viewModeItems ?? []
            itemListView.reloadData()
            guard let submitButtonTitle = template?.submitButtonTitle else { return }
            setUpSubmitButton(title: submitButtonTitle)
        }
    }

    override func setupViews() {
        super.setupViews()
        setUpTableView()
    }

    override func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        template = viewModel.formTemplate()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let key = identifier else {
            return false
        }
        let item = items[textField.tag]
        var formDatePickerViewController : ALKFormDatePickerViewController?

        switch item.type {
        case .time:
            formDatePickerViewController = ALKFormDatePickerViewController(delegate: self,
                                                                           messageKey: key,
                                                                           position: textField.tag,
                                                                           datePickerMode: .time,
                                                                           localizedStringFileName: localizedStringFileName)
        case .date:
            formDatePickerViewController = ALKFormDatePickerViewController(delegate: self,
                                                                           messageKey: key,
                                                                           position: textField.tag,
                                                                           datePickerMode: .date,
                                                                           localizedStringFileName: localizedStringFileName)
        case .dateTimeLocal:
            formDatePickerViewController = ALKFormDatePickerViewController(delegate: self,
                                                                           messageKey: key,
                                                                           position: textField.tag,
                                                                           datePickerMode: .dateAndTime,
                                                                           localizedStringFileName: localizedStringFileName)
        default:
            return true
        }

        guard let datePickerVC = formDatePickerViewController,
              let topVC = ALPushAssist().topViewController else {
            return true
        }

        datePickerVC.modalPresentationStyle = .overCurrentContext
        topVC.present(datePickerVC, animated: true, completion: nil)
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        guard let text = textField.text,
            !text.trim().isEmpty,
            let formSubmitData = formData
        else {
            if let data = formData {
                data.textFields.removeValue(forKey: textField.tag)
                formData = data
            }
            return
        }
        formSubmitData.textFields[textField.tag] = text
        formData = formSubmitData
    }

    private func setUpTableView() {
        itemListView.backgroundColor = .white
        itemListView.estimatedRowHeight = 40
        itemListView.estimatedSectionHeaderHeight = 40
        itemListView.rowHeight = UITableView.automaticDimension
        itemListView.separatorStyle = .singleLine
        itemListView.allowsSelection = false
        itemListView.isScrollEnabled = false
        itemListView.alwaysBounceVertical = false
        itemListView.delegate = self
        itemListView.dataSource = self
        itemListView.tableFooterView = UIView(frame: .zero)
        itemListView.register(ALKFormItemHeaderView.self)
        itemListView.register(ALKFormTextItemCell.self)
        itemListView.register(ALKFormPasswordItemCell.self)
        itemListView.register(ALKFormSingleSelectItemCell.self)
        itemListView.register(ALKFormMultiSelectItemCell.self)
        itemListView.register(ALKFormDateItemCell.self)
        itemListView.register(ALKFormTimeItemCell.self)
        itemListView.register(ALKFormDateTimeItemCell.self)
    }

    private func setUpSubmitButton(title: String) {
        let button = CurvedImageButton(title: title)
        button.delegate = self
        button.index = 1
        submitButton = button
    }
}

extension ALKFormCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return items.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .text:
            let cell: ALKFormTextItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = item
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            return cell
        case .password:
            let cell: ALKFormPasswordItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = item
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            return cell
        case .singleselect:
            guard let singleselectItem = item as? FormViewModelSingleselectItem else {
                return UITableViewCell()
            }
            let cell: ALKFormSingleSelectItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellSelected = {
                if let formSubmitData = self.formData {
                    if formSubmitData.singleSelectFields[indexPath.section] == indexPath.row {
                        formSubmitData.singleSelectFields.removeValue(forKey: indexPath.section)
                    } else {
                        formSubmitData.singleSelectFields[indexPath.section] = indexPath.row
                    }
                    self.formData = formSubmitData
                }
                tableView.reloadSections([indexPath.section], with: .none)
            }
            cell.item = singleselectItem.options[indexPath.row]

            if let formDataSubmit = formData,
                let singleSelectFields = formDataSubmit.singleSelectFields[indexPath.section],
                singleSelectFields == indexPath.row
            {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        case .multiselect:
            guard let multiselectItem = item as? FormViewModelMultiselectItem else {
                return UITableViewCell()
            }
            let cell: ALKFormMultiSelectItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellSelected = {
                if let formDataSubmit = self.formData {
                    if var array = formDataSubmit.multiSelectFields[indexPath.section] {
                        if array.contains(indexPath.row) {
                            array.remove(object: indexPath.row)
                        } else {
                            array.append(indexPath.row)
                        }

                        if array.isEmpty {
                            formDataSubmit.multiSelectFields.removeValue(forKey: indexPath.section)
                        } else {
                            formDataSubmit.multiSelectFields[indexPath.section] = array
                        }
                    } else {
                        formDataSubmit.multiSelectFields[indexPath.section] = [indexPath.row]
                    }
                    self.formData = formDataSubmit
                }
            }

            if let formDataSubmit = formData,
                let multiSelectFields = formDataSubmit.multiSelectFields[indexPath.section], multiSelectFields.contains(indexPath.row)
            {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.item = multiselectItem.options[indexPath.row]
            return cell

        case .date:
            guard let dateSelectItem = item as? FormViewModelDateItem else {
                return UITableViewCell()
            }
            let cell: ALKFormDateItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = dateSelectItem
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            if let timeInMillSecs = formData?.dateFields[indexPath.section] {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let date = Date(timeIntervalSince1970: TimeInterval(timeInMillSecs / 1000))
                let stringDate = formatter.string(from: date)
                cell.valueTextField.text = stringDate
            } else {
                cell.valueTextField.text = ""
            }
            return cell
        case .time:
            guard let timeSelectItem = item as? FormViewModelTimeItem else {
                return UITableViewCell()
            }
            let cell: ALKFormTimeItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = timeSelectItem
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section

            if let timeInMillSecs = formData?.dateFields[indexPath.section] {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                let date = Date(timeIntervalSince1970: TimeInterval(timeInMillSecs / 1000))
                let stringDate = formatter.string(from: date)
                cell.valueTextField.text = stringDate
            } else {
                cell.valueTextField.text = ""
            }
            return cell
        case .dateTimeLocal:
            guard let dateTimeSelectItem = item as? FormViewModelDateTimeLocalItem else {
                return UITableViewCell()
            }

            let cell: ALKFormDateTimeItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = dateTimeSelectItem
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section

            if let timeInMillSecs = formData?.dateFields[indexPath.section] {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy hh:mm a"
                let date = Date(timeIntervalSince1970: TimeInterval(timeInMillSecs / 1000))
                let stringDate = formatter.string(from: date)
                cell.valueTextField.text = stringDate
            } else {
                cell.valueTextField.text = ""
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = items[section]
        guard !item.sectionTitle.isEmpty else { return nil }
        let headerView: ALKFormItemHeaderView = tableView.dequeueReusableHeaderFooterView()
        headerView.item = item
        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let item = items[section]
        guard !item.sectionTitle.isEmpty else { return 0 }
        return UITableView.automaticDimension
    }
}

extension ALKFormCell: Tappable {
    func didTap(index: Int?, title: String) {
        endEditing(true)
        print("tapped submit button in the form")
        guard let tapped = tapped, let index = index else { return }
        tapped(index, title, formData)
    }
}

extension ALKFormCell: ALKDatePickerButtonClickProtocol {
    func confirmButtonClick(position: Int,
                            date: Date,
                            messageKey: String,
                            datePickerMode: UIDatePicker.Mode)
    {
        guard identifier == messageKey else { return }

        var timeInMillSecs: Int64 = 0

        switch datePickerMode {
        case .time:
            timeInMillSecs = Int64(date.timeIntervalSince1970 * 1000)
        case .date:
            timeInMillSecs = Int64(date.timeIntervalSince1970 * 1000)
        case .dateAndTime:
            timeInMillSecs = Int64(date.timeIntervalSince1970 * 1000)
        default:
            break
        }
        guard let formSubmitData = formData,
            timeInMillSecs > 0,
            position < itemListView.numberOfSections
        else {
            print("Can't be updated due to incorrect index")
            return
        }
        formSubmitData.dateFields[position] = timeInMillSecs
        formData = formSubmitData
        itemListView.reloadSections([position], with: .fade)
    }
}

class NestedCellTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

class FormDataSubmit {
    var textFields = [Int: String]()
    var singleSelectFields = [Int: Int]()
    var multiSelectFields = [Int: [Int]]()
    var dateFields = [Int: Int64]()
}
