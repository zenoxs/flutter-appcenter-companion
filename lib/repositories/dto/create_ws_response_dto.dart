import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_ws_response_dto.freezed.dart';

part 'create_ws_response_dto.g.dart';

@freezed
class CreateWSResponseDto with _$CreateWSResponseDto {
  const factory CreateWSResponseDto(
    String url,
  ) = _CreateWSResponseDto;

  factory CreateWSResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateWSResponseDtoFromJson(json);
}
