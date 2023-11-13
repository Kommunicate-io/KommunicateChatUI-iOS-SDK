//
//  ALKFormCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 08/07/20.
//

import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
class ALKFormCell: ALKChatBaseCell<ALKMessageViewModel>, UITextFieldDelegate, UITextViewDelegate {
    
    var cell : KMFormDropDownCell?
    
    enum FormData {
        static let valid = 1
        static let inValid = 2
    }

    public var tapped: ((_ index: Int, _ name: String, _ formDataSubmit: FormDataSubmit?) -> Void)?

    public var onTapOfDateSelect: ((_ index: Int, _ delegate: ALKDatePickerButtonClickProtocol?, _ datePickerMode: UIDatePicker.Mode, _ identifier: String) -> Void)?

    let itemListView = NestedCellTableView()
    var submitButton: CurvedImageButton?
    var identifier: String?
    let formBorderColor: CGColor = UIColor.kmDynamicColor(light: UIColor(red: 230/255, green: 229/255, blue: 236/255, alpha: 1.0), dark: UIColor.darkGray).cgColor
    var activeTextField: UITextField? {
        didSet {
            activeTextFieldChanged?(activeTextField)
        }
    }

    var activeTextView: UITextView? {
        didSet {
            activeTextViewChanged?(activeTextView)
        }
    }

    var activeTextFieldChanged: ((UITextField?) -> Void)?
    var activeTextViewChanged: ((UITextView?) -> Void)?
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
        if viewModel.isFormSubmitted() {
            itemListView.isUserInteractionEnabled = false
        } else {
            itemListView.isUserInteractionEnabled = true
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let key = identifier else {
            return false
        }
        let item = items[textField.tag]
        var datePickerMode: UIDatePicker.Mode?
        switch item.type {
        case .time:
            datePickerMode = .time
        case .date:
            datePickerMode = .date
        case .dateTimeLocal:
            datePickerMode = .dateAndTime
        default:
            return true
        }

        guard let pickerMode = datePickerMode,
              let dateSelectTap = onTapOfDateSelect
        else {
            return true
        }

        dateSelectTap(textField.tag, self, pickerMode, key)
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

    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        textView.text = nil
        textView.textColor = .kmDynamicColor(light: .black, dark: .white)
    }

    func textViewDidChange(_ textView: UITextView) {
        textView.textColor = .kmDynamicColor(light: .black, dark: .white)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
        guard let text = textView.text,
              !text.trim().isEmpty,
              let formSubmitData = formData
        else {
            if let data = formData {
                data.textViews.removeValue(forKey: textView.tag)
                formData = data
            }
            return
        }
        formSubmitData.textViews[textView.tag] = text
        formData = formSubmitData
    }

    func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText _: String) -> Bool {
        return true
    }

    private func setUpTableView() {
        itemListView.backgroundColor = UIColor.kmDynamicColor(light: .white, dark: UIColor.appBarDarkColor())
        itemListView.estimatedRowHeight = 50
        itemListView.estimatedSectionHeaderHeight = 50
        itemListView.rowHeight = UITableView.automaticDimension
        itemListView.separatorStyle = .singleLine
        itemListView.allowsSelection = false
        itemListView.isScrollEnabled = false
        itemListView.alwaysBounceVertical = false
        itemListView.delegate = self
        itemListView.dataSource = self
        itemListView.layer.borderColor = formBorderColor
        itemListView.layer.borderWidth = 1
        itemListView.layer.cornerRadius = 5
        if #available(iOS 15.0, *) {  /// this is to remove the extra top padding form the cell
            itemListView.sectionHeaderTopPadding = 0
        }
        itemListView.tableFooterView = UIView(frame: .zero)
        itemListView.register(ALKFormItemHeaderView.self)
        itemListView.register(ALKFormTextItemCell.self)
        itemListView.register(ALKFormTextAreaItemCell.self)
        itemListView.register(ALKFormPasswordItemCell.self)
        itemListView.register(ALKFormSingleSelectItemCell.self)
        itemListView.register(ALKFormMultiSelectItemCell.self)
        itemListView.register(KMFormMultiSelectButtonItemCell.self)
        itemListView.register(ALKFormDateItemCell.self)
        itemListView.register(ALKFormTimeItemCell.self)
        itemListView.register(ALKFormDateTimeItemCell.self)
        itemListView.register(KMFormDropDownCell.self)
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
            if let formDataSubmit = formData,
               let text = formDataSubmit.textFields[indexPath.section]
            {
                cell.valueTextField.text = text
            } else {
                cell.valueTextField.text = ""
            }
            if let validationField = formData?.validationFields[indexPath.section], validationField == FormData.inValid {
                let formViewModelTextItem = item as? FormViewModelTextItem
                cell.errorLabel.text = formViewModelTextItem?.validation?.errorText ?? localizedString(forKey: "InvalidDatErrorInForm", withDefaultValue: SystemMessage.UIError.InvalidDatErrorInForm, fileName: localizedStringFileName)
                cell.errorLabel.isHidden = false
            } else {
                cell.errorLabel.isHidden = true
            }
            return cell
        case .textarea:
            let cell: ALKFormTextAreaItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = item
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            if let validationField = formData?.validationFields[indexPath.section], validationField == FormData.inValid {
                let formViewModelTextAreaItem = item as? FormViewModelTextAreaItem
                cell.errorLabel.text = formViewModelTextAreaItem?.validation?.errorText ?? localizedString(forKey: "InvalidDatErrorInForm", withDefaultValue: SystemMessage.UIError.InvalidDatErrorInForm, fileName: localizedStringFileName)
                cell.errorLabel.isHidden = false
            } else {
                cell.errorLabel.isHidden = true
            }
            return cell
        case .password:
            let cell: ALKFormPasswordItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = item
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            if let formDataSubmit = formData,
               let text = formDataSubmit.textFields[indexPath.section]
            {
                cell.valueTextField.text = text
            } else {
                cell.valueTextField.text = ""
            }
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
            if let checkForFormSubmitted = viewModel?.isFormSubmitted() , checkForFormSubmitted {
                cell.tintColor = .darkGray
            } else {
                cell.tintColor = UIColor.systemBlue
            }
            return cell
        case .multiselect:
            guard let multiselectItem = item as? FormViewModelMultiselectItem else {
                return UITableViewCell()
            }
            if KMMultipleSelectionConfiguration.shared.enableMultipleSelectionOnCheckbox {
                itemListView.separatorStyle = .none
                let cell: KMFormMultiSelectButtonItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
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
                    
                    cell.update(item: multiselectItem.options[indexPath.row],isChecked : true)

                    } else {
                        cell.update(item: multiselectItem.options[indexPath.row])
                }
                if let checkForFormSubmitted = viewModel?.isFormSubmitted() , checkForFormSubmitted {
                    cell.button.layer.borderColor = KMMultipleSelectionConfiguration.shared.postSubmitBorderColor.cgColor
                    cell.button.label.textColor = KMMultipleSelectionConfiguration.shared.postSubmitTitleColor
                    cell.button.imageView.image = KMMultipleSelectionConfiguration.shared.postSubmitImage
                }
                return cell
            } else {
                let cell: ALKFormMultiSelectItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                itemListView.separatorStyle = .singleLine
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
                if let checkForFormSubmitted = viewModel?.isFormSubmitted() , checkForFormSubmitted {
                    cell.tintColor = .darkGray
                } else {
                    cell.tintColor = UIColor.systemBlue
                }
                return cell
            }
        case .date:
            guard let dateSelectItem = item as? FormViewModelDateItem else {
                return UITableViewCell()
            }
            let cell: ALKFormDateItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.item = dateSelectItem
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.section
            if let timeInMillSecs = formData?.dateFields[indexPath.section] {
                let dateFormate = Date.is24HrsFormate() ? Date.Formates.Date.twentyfour : Date.Formates.Date.twelve
                cell.valueTextField.text = Date.formatedDate(formateString: dateFormate, timeInMillSecs: timeInMillSecs)
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
                let timeFormate = Date.is24HrsFormate() ? Date.Formates.Time.twentyfour : Date.Formates.Time.twelve
                cell.valueTextField.text = Date.formatedDate(formateString: timeFormate, timeInMillSecs: timeInMillSecs)
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
                let dateTimeFromate = Date.is24HrsFormate() ? Date.Formates.DateAndTime.twentyfour : Date.Formates.DateAndTime.twelve
                cell.valueTextField.text = Date.formatedDate(formateString: dateTimeFromate, timeInMillSecs: timeInMillSecs)
            } else {
                cell.valueTextField.text = ""
            }
            return cell
        case .dropdown:
            print("Drop Down Support ")
            let cell: KMFormDropDownCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.menu.optionArray.removeAll()
            cell.menu.text = ""
            cell.item = item
            cell.menu.tag = indexPath.section
            cell.delegate = self
            self.cell = cell
            
            if let formDataSubmit = formData,
               let fields = formDataSubmit.dropDownFields[indexPath.section]{
                cell.menu.selectedIndex = fields.0
                cell.menu.text = cell.menu.optionArray[fields.0]
            }
            
            if let validationField = formData?.validationFields[indexPath.section], validationField == FormData.inValid {
                let formViewModelDropdownItem = item as? FormViewModelDropdownItem
                cell.errorLabel.text = formViewModelDropdownItem?.validation?.errorText ?? localizedString(forKey: "InvalidDataErrorInForm", withDefaultValue: SystemMessage.UIError.InvalidDatErrorInForm, fileName: localizedStringFileName)
                cell.errorLabel.isHidden = false
            } else {
                cell.errorLabel.isHidden = true
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

extension ALKFormCell: KMFormDropDownSelectionProtocol {
    func optionSelected(position: Int, selectedText: String?, index: Int) {
        guard let formSubmittedData = formData,
              position < itemListView.numberOfSections
        else {
            print("Can't be updated due to incorrect index")
            return
        }
        formSubmittedData.dropDownFields[position] = (index,selectedText)
        formData = formSubmittedData
    }
}

extension ALKFormCell {
    func isFormDataValid() -> Bool {
        var isValid = true

        guard let formDataSubmit = formData,
              let viewModelItems = template?.viewModeItems
        else {
            return false
        }
        // Loop and match all the text types for validation and mark them as valid or inValid.
        for index in 0 ..< viewModelItems.count {
            let element = viewModelItems[index]

            switch element.type {
            case .text:
                let textFieldModel = element as? FormViewModelTextItem
                let enteredText = formDataSubmit.textFields[index] ?? ""

                if let validation = textFieldModel?.validation,
                   let regxPattern = validation.regex
                {
                    do {
                        let isCurrentValid = try ALKRegexValidator.matchPattern(text: enteredText, pattern: regxPattern)
                        isValid = isValid && isCurrentValid
                        formDataSubmit.validationFields[index] = isCurrentValid ? FormData.valid : FormData.inValid
                        formData = formDataSubmit
                    } catch {
                        print("Error while matching text: \(error.localizedDescription)")
                    }
                }

            case .textarea:
                let textFieldModel = element as? FormViewModelTextAreaItem
                let enteredText = formDataSubmit.textViews[index] ?? ""

                if let validation = textFieldModel?.validation,
                   let regxPattern = validation.regex
                {
                    do {
                        let isCurrentValid = try ALKRegexValidator.matchPattern(text: enteredText, pattern: regxPattern)
                        isValid = isValid && isCurrentValid
                        formDataSubmit.validationFields[index] = isCurrentValid ? FormData.valid : FormData.inValid
                        formData = formDataSubmit
                    } catch {
                        print("Error while matching text: \(error.localizedDescription)")
                    }
                }
                
            case .dropdown:
                let dropdownItem = element as? FormViewModelDropdownItem
                
                guard let validation = dropdownItem?.validation else {
                    formDataSubmit.validationFields[index] = FormData.valid
                    formData = formDataSubmit
                    continue
                }
                
                guard let selectedIndex = self.cell!.menu.selectedIndex else {
                    isValid = false
                    formDataSubmit.validationFields[index] = FormData.inValid
                    formData = formDataSubmit
                    continue
                }

                var disabled = dropdownItem?.options[selectedIndex].disabled
                
                if(disabled == nil){
                    if (dropdownItem?.options[selectedIndex].value == nil) {
                        isValid = false
                        formDataSubmit.validationFields[index] = FormData.inValid
                    } else {
                        formDataSubmit.validationFields[index] = FormData.valid
                    }
                } else {
                    if (dropdownItem?.options[selectedIndex].value == nil) {
                        isValid = isValid && !disabled!
                        formDataSubmit.validationFields[index] = disabled! ? FormData.inValid : FormData.valid
                    } else {
                        formDataSubmit.validationFields[index] = FormData.valid
                    }
                }
                
                formData = formDataSubmit
                
            default:
                break
            }
        }
        return isValid
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
    var textViews = [Int: String]()
    var singleSelectFields = [Int: Int]()
    var multiSelectFields = [Int: [Int]]()
    var dateFields = [Int: Int64]()
    var dropDownFields = [Int: (Int,String?)]()
    var validationFields = [Int: Int]()
}

public struct KMHidePostCTAForm {
    static var shared = KMHidePostCTAForm()
    var enabledHidePostCTAForm: Bool = false
    var disableSelectionAfterSubmision: Bool = false
}
